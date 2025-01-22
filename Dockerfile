FROM ghcr.io/appleboy/gitea-secret-sync:0.1.0

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
