FROM pierrezemb/gostatic

COPY ./output/. /srv/http/
CMD ["-enable-health", "-log-level info", "-fallback 404.html"]
