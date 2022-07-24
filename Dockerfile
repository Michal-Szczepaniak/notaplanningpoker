FROM mhart/alpine-node:16 as builder
WORKDIR /opt/napp
COPY . .
RUN yarn install
RUN yarn build

FROM opensuse/leap:latest as runtime
COPY --from=builder /opt/napp/dist /srv/www/notaplanningpoker
RUN zypper in -y nginx
COPY docker/nginx.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]
