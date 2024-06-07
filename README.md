This repository contains the configuraiton to build a packer image with the vault binary baked in, configure vault for AWS IAM authentication, and an AWS ASG to run a dockerized Nextjs Demo App

The app is already built at hashicoop/nextjs-demo-app and only needs a Postgres database with the schema definied in app/prisma/prisma.shcema and then a valid postgres connection string set as an environment variable. Prisma can automatically generate the schema in the db which is how I ran the app but the ability to run a migration from the final docker build is something I still need to implement so you need to install and run prisma locally to take advantage of automatic creation of the "Users" table if you don't want to do it manually. Also, prisma supports a number of different database backends that I can expand the app to cover but haven't done yet.

Once those are setup run:

docker run -p 80:3000 -e $POSTGRES_URL hashicoop/nextjs-demo-app