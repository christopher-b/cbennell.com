---
title: "Using Ruby Structs to Model API Responses"
date: "2024-05-05"
categories: 
  - "ruby"
tags: 
  - "api"
  - "dev"
  - "ruby"
  - "struct"
coverImage: "AdobeStock_710819717-scaled-1.jpeg"
---

Here's a technique I use when I want to wrap an API response in a simple class, rather than use a raw hash result. It allows easier access to the object properties, and allows you to attach some instance methods, with a minimal amount of boilerplate.

This is helpful if I want to access the member data using dot notation, rather than index keys.

```
# Yuck
user[:id]

# Yaa
user.id
```

This isn't just for aesthetics. Having the properties be method-like means we can use nice features like the _ampersand and object_ operator.

```
users.map(&:id)
```

Here's the approach.

```
module Api
  USER_ATTRIBUTES = %i[
    id
    first_name
    last_name
    email
  ]
  
  User = Struct.new(*USER_ATTRIBUTES, keyword_init: true) do
    def initialize(params)
      super(params.slice(*USER_ATTRIBUTES))
    end
  end
end

user = Api::User.new(
  id: 99, 
  first_name: "Bob", 
  last_name: "Loblaw" 
  email: "bob@loblaw.blaw"
)
```

We declare a list of properties from the API response that we're interested in. We use those as the keywords provided to the Struct constructor, so our models will only contain those properties. We use that same list of desired attributes to filter the parameters that are used passed to `#new`, so even if our API returns additional properties, our Struct won't complain about extra keyword arguments when we instantiate them.

We can define additional methods on our models.

```
module Api
  USER_ATTRIBUTES = %i[
    id
    first_name
    last_name
    email
  ]
  
  User = Struct.new(*USER_ATTRIBUTES, keyword_init: true) do
    def initialize(params)
      super(params.slice(*USER_ATTRIBUTES))
    end
    
    def sortable_name
      "#{last_name}, #{first_name}"
    end

    def self.load(id)
      user_response_hash = api_client.get("user/#{id}")
      new(user_response_hash)
    end
  end
end

user = Api::User.load(99)
user.sortable_name
```

If we don't want to filter the properties, and can accept everything the API sends along, we can simplify it.

```
module Api
  User = Struct.new(:id, :first_name, :last_name, :email: keyword_init: true) do
    def sortable_name
      "#{last_name}, #{first_name}"
    end

    def self.load(id)
      user_response_hash = api_client.get("user/#{id}")
      new(user_response_hash)
    end
  end
end
```