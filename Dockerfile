FROM ghcr.io/appleboy/gitea-secret-sync:0.0.5

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
