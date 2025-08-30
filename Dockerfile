FROM ghcr.io/appleboy/gitea-secret-sync:1.0.0

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
