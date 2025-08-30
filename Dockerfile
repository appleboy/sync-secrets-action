FROM ghcr.io/appleboy/gitea-secret-sync:latest

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
