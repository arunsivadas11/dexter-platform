# 👋 About Me

> **Personal portfolio website for Arun Sivadas --- Solutions Architect**

[![Live
Site](https://img.shields.io/badge/Live%20Site-dexterapp.dev-0f172a?style=for-the-badge&logo=googlechrome&logoColor=white)](https://dexterapp.dev)
[![Firebase
Hosting](https://img.shields.io/badge/Hosting-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com/docs/hosting)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)](https://github.com/features/actions)
[![Node.js](https://img.shields.io/badge/Node.js-CI%20Build-339933?style=for-the-badge&logo=nodedotjs&logoColor=white)](https://nodejs.org/)

**Production:** <https://dexterapp.dev>

------------------------------------------------------------------------

## 📌 Overview

The `aboutme` application is a responsive, minimalist personal portfolio
website.

It is a static web application hosted on **Firebase Hosting**, with
production deployments fully automated through **GitHub Actions**.

> 💡 **Deployment principle:** A push to `main` is all that is required
> to release a new version. Production deployment does not depend on a
> developer's local machine.

------------------------------------------------------------------------

## 🏗️ Application Structure

``` text
dexter-platform/
│
├── aboutme/
│   ├── src/                 # Application source
│   ├── public/              # Static assets
│   ├── package.json         # Dependencies and scripts
│   ├── package-lock.json    # Locked dependency versions
│   └── dist/                # Generated production build
│
├── .github/
│   └── workflows/           # CI/CD workflows
│
├── firebase.json             # Firebase Hosting configuration
└── .firebaserc               # Firebase project configuration
```

### 📂 Build output

The production build is generated under:

``` text
aboutme/dist/
```

`dist/` is generated output and should not be edited manually.

------------------------------------------------------------------------

## 💻 Local Development

From the repository root:

``` bash
cd aboutme
```

### Install dependencies

``` bash
npm ci
```

### Start development server

``` bash
npm run dev
```

### Create a production build

``` bash
npm run build
```

The generated production files will be placed in:

``` text
aboutme/dist/
```

> 📝 The Node.js version used by CI should be treated as the
> authoritative build environment. Local development should use a
> compatible supported Node.js version.

------------------------------------------------------------------------

## 🚀 CI/CD Pipeline

Production releases are triggered automatically when changes are pushed
to `main`.

``` mermaid
flowchart LR
    A[👨‍💻 Git Push] --> B[GitHub]
    B --> C[⚙️ GitHub Actions]
    C --> D[📦 Install Dependencies]
    D --> E[🔨 Build]
    E --> F[🔐 Google Cloud Auth]
    F --> G[🔥 Firebase Hosting]
    G --> H[🌐 dexterapp.dev]
```

### Pipeline stages

  Stage             Purpose
  ----------------- --------------------------------------------------------
  📥 Checkout       Retrieves the latest source from GitHub
  🟢 Node.js        Configures the CI build environment
  📦 Install        Runs `npm ci`
  🔨 Build          Runs the production build
  🔐 Authenticate   Uses Workload Identity Federation
  🔥 Deploy         Publishes the build to Firebase Hosting
  🌐 Live           Application becomes available on the production domain

### Normal release process

``` bash
git add .
git commit -m "Update About Me website"
git push origin main
```

That's it.

> ✅ **No manual production deployment is required.** The GitHub Actions
> workflow handles the release.

------------------------------------------------------------------------

## 🔐 Google Cloud Authentication

GitHub Actions authenticates to Google Cloud using **Workload Identity
Federation (WIF)**.

Long-lived Google service-account JSON keys are **not** stored in the
repository.

The workflow requires GitHub's OIDC permission:

``` yaml
permissions:
  contents: read
  id-token: write
```

The authentication step follows this pattern:

``` yaml
- name: Authenticate to Google Cloud
  uses: google-github-actions/auth@v2
  with:
    workload_identity_provider: ${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}
    service_account: ${{ secrets.GCP_SERVICE_ACCOUNT }}
```

### Why WIF?

  Traditional key-based deployment   WIF-based deployment
  ---------------------------------- ------------------------------
  🔴 Long-lived credentials          🟢 Short-lived credentials
  🔴 JSON key management             🟢 No key file
  🔴 Key rotation required           🟢 OIDC-based authentication
  🔴 Credential stored somewhere     🟢 Identity-based access

> 🔒 Keep infrastructure identifiers and credentials in the appropriate
> GitHub/GCP configuration rather than unnecessarily duplicating them in
> public application documentation.

------------------------------------------------------------------------

## 🔥 Firebase Hosting

The application is hosted using **Firebase Hosting**.

### Hosting endpoints

  ----------------------------------------------------------------------
  Environment                        URL
  ---------------------------------- -----------------------------------
  🌐 Production                      **<https://dexterapp.dev>**

  🔥 Firebase                        <https://dexter-platform.web.app>
  ----------------------------------------------------------------------

Firebase configuration is stored in:

``` text
.firebaserc
firebase.json
```

The Hosting public directory is:

``` text
aboutme/dist
```

Example configuration:

``` json
{
  "hosting": {
    "public": "aboutme/dist",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ]
  }
}
```

The Firebase CLI deployment command is conceptually:

``` bash
firebase deploy --only hosting
```

However, this is executed by CI/CD for normal production releases.

------------------------------------------------------------------------

## 🌍 Domain & HTTPS

### Production domain

**<https://dexterapp.dev>**

The custom domain is connected to Firebase Hosting and uses a
Firebase-managed HTTPS certificate.

DNS configuration is maintained separately from the application source.

> ℹ️ DNS provider-specific records are intentionally not reproduced
> here. Firebase provides the authoritative DNS values when configuring
> the custom domain.

------------------------------------------------------------------------

## 🛡️ Security Guidelines

Because this repository is public, **never commit secrets or
credentials**.

### ❌ Never commit

-   🔑 Service-account JSON keys
-   🔐 Private keys
-   🎟️ API tokens
-   🔒 Passwords
-   🔑 OAuth client secrets
-   🔥 Firebase Admin credentials
-   🗄️ Database credentials
-   🪪 Personal access tokens
-   Any other production secrets

### ✅ Preferred approach

Use:

-   **Workload Identity Federation** for GitHub → Google Cloud
    authentication
-   **GitHub Actions configuration/secrets** for CI-specific
    configuration where appropriate
-   **Google Secret Manager** for application secrets when required
-   **IAM least privilege** for cloud access

> ⚠️ Never solve an authentication problem by committing a credential
> file to the repository.

------------------------------------------------------------------------

## ⚙️ GitHub Actions Security

The deployment workflow should use the minimum permissions required:

``` yaml
permissions:
  contents: read
  id-token: write
```

The Google Cloud Workload Identity configuration should restrict which
GitHub repository and branch are permitted to authenticate.

Do not weaken the WIF attribute condition simply to make authentication
succeed.

------------------------------------------------------------------------

## 🔍 Deployment Verification

After pushing to `main`:

### 1. Check GitHub Actions

Open:

``` text
GitHub
→ dexter-platform
→ Actions
```

Verify that the About Me workflow completed successfully.

Expected result:

``` text
Checkout                  ✓
Setup Node.js             ✓
Install dependencies      ✓
Build                     ✓
Google Cloud Auth         ✓
Firebase deployment       ✓
```

### 2. Check production

Open:

**<https://dexterapp.dev>**

Confirm that the latest changes are visible.

### 3. Optional Firebase check

The Firebase-provided hosting URL can also be used to verify the
deployment independently:

**<https://dexter-platform.web.app>**

------------------------------------------------------------------------

## 🧰 Troubleshooting

### 🔨 Build failure

Reproduce the CI build locally:

``` bash
cd aboutme
npm ci
npm run build
```

Resolve build errors before pushing to `main`.

------------------------------------------------------------------------

### 🔐 WIF authentication failure

Check:

-   GitHub Actions `id-token: write` permission
-   Workload Identity Provider configuration
-   Repository/branch attribute condition
-   Deployment service-account IAM permissions
-   Values supplied to the authentication action

Avoid adding broad IAM roles without first identifying the missing
permission.

------------------------------------------------------------------------

### 🔥 Firebase project error

Check:

``` bash
cat .firebaserc
```

The configured production Firebase project should be:

``` text
dexter-platform
```

------------------------------------------------------------------------

### 🚫 Firebase deployment permission error

Verify that the GitHub deployment identity has the required Firebase
Hosting permissions for the production Firebase project.

------------------------------------------------------------------------

### 🌍 Custom domain issue

Check:

1.  Firebase Hosting custom-domain status
2.  DNS configuration
3.  DNS propagation
4.  SSL certificate status

Use the DNS values provided by Firebase when changing the custom-domain
configuration.

------------------------------------------------------------------------

## 📊 Production Status

  Component                                Status
  ------------------------------------- -------------
  🧑‍💻 Website source                      🟢 Complete
  🔨 Production build                    🟢 Complete
  ⚙️ GitHub Actions                      🟢 Complete
  🔐 WIF authentication                  🟢 Complete
  🔥 Firebase Hosting                    🟢 Complete
  🌍 Custom domain                       🟢 Complete
  🔒 HTTPS certificate                   🟢 Complete
  🚀 Automatic deployment from `main`    🟢 Complete

------------------------------------------------------------------------

## 📎 Quick Reference

  Item                      Value
  ------------------------- -------------------------------------
  🌐 Production             **https://dexterapp.dev**
  🔥 Firebase Hosting       **https://dexter-platform.web.app**
  📁 Application            `aboutme/`
  📦 Build output           `aboutme/dist/`
  🔄 Deployment trigger     Push to `main`
  ⚙️ CI/CD G                itHub Actions
  🔐 Cloud authentication   Workload Identity Federation
  🏠 Hosting                Firebase Hosting

------------------------------------------------------------------------

## 👤 Maintainer

**Arun Sivadas**\
*Solutions Architect*

-   💼 [LinkedIn](https://www.linkedin.com/in/arunsivadas11/)
-   🐙 [GitHub](https://github.com/arunsivadas11/)
-   🌐 [Website](https://dexterapp.dev)

------------------------------------------------------------------------

```{=html}
<p align="center">
```
`<strong>`{=html}Built with a simple goal: keep the application simple,
secure, and easy to deploy.`</strong>`{=html}

```{=html}
</p>
```
