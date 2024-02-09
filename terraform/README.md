This terraform code creates:

- an EK cluster
- 2 ecr repositories
- An aws user with access keys for github actions
- User group to access Ecr and Eks
- Permssions are assigned to groups
- User is assigned to groups
- The codebuild infrastructure is commented but can be used as runner instead of github 
