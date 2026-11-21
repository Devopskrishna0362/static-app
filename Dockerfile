
FROM nginx:1.27-alpine

WORKDIR /d/devops-static-app/html

COPY index.html .
COPY style.css .
COPY script.js .

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
