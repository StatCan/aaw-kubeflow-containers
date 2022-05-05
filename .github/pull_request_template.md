# Description

**What your PR adds/fixes/removes**

# Tests / Quality Checks


## Are there breaking changes?
Ask yourself the next question;
- [ ] Do we want to maintain the previous image from which we had to do breaking changes from?

If no, then carry on. If yes, there is a breaking change and we **want to maintain the previous image** do the following
- [ ] Create a new branch for the current version (ex v1) based off the current master/main branch
- [ ]  Increment the tag in the CI for pushes to master/main (v1 to v2)
- [ ] Change the CI that on pushes to the newly created "v1" branch (the name of the newly created branch we want to maintain is) it will push to the ACR. 
## Automated Testing/build and deployment
- [ ] Does the image pass CI successfully (build, pass vulnerability scan, and pass automated test suite)?
- [ ] If new features are added (new image, new binary, etc), have new automated tests been added to cover these?
- [ ] If new features are added that require in-cluster testing (e.g. a new feature that needs to interact with kubernetes), have you added the `auto-deploy` tag to the PR before pushing in order to build and push the image to ACR so you can test it in cluster as a custom image?

## JupyterLab extensions

- [ ] Are all extensions "enabled" (`jupyter labextension list` from inside the notebook)?

## VS Code tests

- [ ] Does VS Code open?
- [ ] Can you install extensions?

## Code review

- [ ] Have you added the `auto-deploy` tag to your PR before your most recent push to this repo?  This causes CI to build the image and push to our ACR, letting reviewers access the built image without having to create it themselves
- [ ] Have you chosen a reviewer, attached them as a reviewer to this PR, and messaged them with the SHA-pinned image name for the final image to test on the **dev cluster** (e.g. `k8scc01covidacrdev.azurecr.io/jupyterlab-cpu:746d058e2f37e004da5ca483d121bfb9e0545f2b`)?
