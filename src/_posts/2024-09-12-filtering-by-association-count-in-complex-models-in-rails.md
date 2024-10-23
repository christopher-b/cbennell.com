---
title: Filtering by Association Count in Complex Models in Rails
date: 2024-09-12
tags:
  - performance
  - ruby
  - ruby-on-rails
coverImage: pegs.jpeg
---

I recently tried to optimize a slow page, and bumped into some limitations in the way Rails works with complex associations. The models I'm working with are `Courses`, `Users`, and `Enrollments`. There is a many-to-many relationship between `Courses` and `Users`, with `Enrollments` acting as the join model. Enrollments also have a `role`, indicating if the user is a student, a teacher, etc. I’ve implemented some unconventional `has_many` relationships, which I may explain in a future post.



{% code ruby caption="app/models/course.rb" %}
class Course < ApplicationRecord
  has_many :enrollments
  has_many :teacher_enrollments, -> { teacher.eager_load(:user) }, class_name: "Enrollment"
  has_many :student_enrollments, -> { student.eager_load(:user) }, class_name: "Enrollment"
  has_many :users, through: :enrollments, inverse_of: :courses
  has_many :teachers, through: :teacher_enrollments, source: :user
  has_many :students, through: :student_enrollments, source: :user
end
{% endcode %}



{% code ruby caption="app/models/user.rb" %}
class User < ApplicationRecord
  has_many :enrollments
  has_many :courses, through: :enrollments, inverse_of: :user
end
{% endcode %}



{% code ruby caption="app/models/enrollment.rb" %}
class Enrollment < ApplicationRecord
  belongs_to :course
  belongs_to :user

  scope :teacher, -> { where(role: "teacher") }
  scope :student, -> { where(role: "student") }
end
{% endcode %}

## The Problem

My view needs to display a large list of courses, along with the teacher's name. It also needs to **not show courses with zero enrolled students**.

My initial, naive, slow version looked something like this:

{% code ruby %}
# SLOW
Course
  .includes(
    :teachers,
    :students
  )
  .select { |c| c.students.any? }
{% endcode %}

The issue arose because I was loading a large set of student data just to check for student enrollment, which significantly slowed down the query: it had to load all the enrollments and user objects, even though I wasn't using any of that information.

I tried various approaches to solving this. The most promising seemed to be Rails' [`where.associated`](https://guides.rubyonrails.org/active_record_querying.html#where-associated-and-where-missing), which is the inverse of `where.missing`. These methods are supposed to "let you select a set of records based on the presence or absence of an association", which seemed ideal. However, applying this did not give the desired results. I tried both

{% code ruby %}
# Naive approach: loads all students and teachers, then filters courses with students.
Course
  .where.associated(:students)
  .includes(:teachers)
{% endcode %}

and

{% code ruby %}
Course
  .where.associated(:student_enrollments)
  .includes(:teachers)
{% endcode %}

Both of these queries resulted in very large result sets, with duplicated course records in the response, likely due to issues with the SQL join caused by the "through" associations. I didn't dig into the details, but I'm curious why this happened; perhaps it's an opportunity to contribute an enhancement to Rails.

## The Solution

Since the Rails built-in solution didn’t work, I turned to SQL. The SQL I needed ended up looking like this:

{% code sql %}
SELECT
  courses.*,
  (
    SELECT count(*)
    FROM enrollments
    WHERE enrollments.course_id = courses.id and enrollments.role = 'student'
  ) as student_count
FROM courses
WHERE student_count > 0
{% endcode %}

I'm not an SQL expert; it's possible that a JOIN could be faster.

Now, how to express that in my Rails models? It turns out that scopes work nicely for this. I settled on using two scopes to express the two different elements of this query: computing the `student_count` and filtering for courses with students. This makes the code a bit more clear and would allow me to reuse the student count in other contexts.



{% code ruby caption="app/models/course.rb" %}
class Course < ApplicationRecord
  has_many :enrollments
  has_many :teacher_enrollments, -> { teacher.eager_load(:user) }, class_name: "Enrollment"
  has_many :student_enrollments, -> { student.eager_load(:user) }, class_name: "Enrollment"
  has_many :users, through: :enrollments, inverse_of: :courses
  has_many :teachers, through: :teacher_enrollments, source: :user
  has_many :students, through: :student_enrollments, source: :user

  # Adding scopes to filter courses by student count
  scope :with_student_count, -> {
    select("courses.*, (select count(*) from enrollments where enrollments.course_id = courses.id and enrollments.role = 'student') as student_count")
  }
  scope :has_students, -> { with_student_count.where("student_count > ?", 0) }
end
{% endcode %}

Now we can use the `has_students` scope in our original query:

{% code ruby %}
Course
  .has_students
  .includes(:teachers)
{% endcode %}

This change significantly reduced the response time on my page load.

I always reach for the Rails built-in methods like `where.associated` when I can, but sometimes complex models and specific requirements necessitate more custom solutions. In this case, leveraging raw SQL within Rails scopes provided the flexibility and efficiency needed to solve the problem of filtering courses by student enrollment count without loading unnecessary data. The solution—using a SQL subquery in combination with Rails scopes—demonstrates how Rails allows us to seamlessly integrate SQL for performance optimizations, keeping the code clean and reusable while significantly improving response times.
