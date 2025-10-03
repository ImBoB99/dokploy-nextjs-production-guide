# Deploy a Next.js + Prisma App to Dokploy with GitHub Actions and Docker Hub

This repository documents how to:

1. Build a Next.js app (with Prisma support) using GitHub Actions
2. Publish the Docker image to Docker Hub
3. Deploy the image to a Dokploy instance

-- Note: these instructions work fine for private github repo + private docker hub repo, and should work for public repos as well.

Keywords: **Next.js**, **Prisma**, **Docker**, **Docker Hub**, **GitHub Actions**, **CI/CD**, **Dokploy**

---

## Prerequisites

- A Next.js project in a GitHub repository
- Prisma configured (optional, remove `#PRISMA` lines in Dockerfile if not using Prisma)
- Docker Hub account with repository created
- Running Dokploy instance

---

## 1. Configure Next.js for standalone build

In your `next.config.js` file, enable standalone output:

```js
const nextConfig = {
  output: 'standalone',
};
```

## 2. Create Dockerfile

Place a Dockerfile in the root of your Next.js project. Example Dockerfile can be found in this repo.

- change node:22 to whatever version of node you're using
- remove lines referencing prisma below the `#PRISMA` comment in Dockerfile if not using Prisma
- if you do use Prisma, make sure the paths point to the generated Prisma folder in the root if your project, for older Prisma projects this generated Prisma folder may be somewhere else.

## 3. Add Github Actions Workflow

Create .github/workflows/deploy.yml file in your Next.js project. Example workflow file can be found in .github/workflows/deploy.yml in this repo.

- change branches: ['live'] line to whatever branch you want to trigger builds with
- change /YourAPP:latest in the tags line to whatever your docker hub image name is

## 4. Create Docker Hub account, Personal Access Token & Docker Hub Repo

1. Register an account on Docker Hub
2. Go to settings/personal access tokens
3. Create new personal access token, name it github-actions, give it read/write/delete rights
4. Save the personal access token somewhere safe, it looks like 'dckr_pat_XXXXXXXXXXXXX'
5. Go to your Docker Hub repositories, create new repository, use name: "nextjs-app" or something similar and choose private repository option.

## 5. Add github-actions Docker Hub PAT to your github repo

1. Go to your github repo, choose Settings/Secrets and Variables/Actions
2. Add new repository secret: name DOCKERHUB_TOKEN and paste in your github-actions Docker Hub PAT token
3. Add new repository secret: name DOCKERHUB_USERNAME and paste in your Docker Hub username

At this point, pushing to the live branch of your repo should trigger a build action and push the built image to the Docker Hub repo successfully, now let's configure deployment with Dokploy.

## 6. Create Docker Hub Personal Access Token for Dokploy Deployments

1. Go to settings/personal access tokens
2. Create new personal access token, name it whatever you want, give it read/write/delete rights
3. Save the personal access token somewhere safe, it looks like 'dckr_pat_XXXXXXXXXXXXX'

## 7. Configure Dokploy to deploy the Docker Hub image

1. Log in to your Dokploy dashboard
2. Create your project if you haven't yet
3. Inside project, click Create Service -> Application
4. Add any Environment variables your app may need, as well as the domain
5. Under Provider pick Docker
6. Fill in all the Docker fields:

- Docker Image is the username/reponame:latest that you can see at the top of your screen when you're in your Docker Hub repo
- Registry url for Docker Hub is docker.io
- Username is your Docker Hub login username (and also the same one you use in the Docker Image step)
- Password is the Docker Hub Personal Access Token (PAT) we generated for Dokploy Deployments
- Click save.

## Deploy Remote Built Docker Image to Dokploy

1. In the General tab under Deploy Settings click the deploy button and that's it!

Congratulations, you have now built a an automated Next.js CI/CD pipeline that builds the image with Github Actions, pushes the image to Docker Hub for easy deployments with Dokploy.
