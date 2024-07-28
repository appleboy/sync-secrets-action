FROM ghcr.io/appleboy/gitea-secret-sync:main

COPY entrypoint.sh /bin/entrypoint.sh

ENTRYPOINT ["/bin/entrypoint.sh"]
