FROM node:17
COPY . .
RUN yarn install
CMD ["yarn", "serve"]
