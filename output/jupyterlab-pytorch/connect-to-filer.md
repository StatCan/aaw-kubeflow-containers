Welcome! These are instructions to connect to your filer.
To connect to the filer we make use of the minio client as seen here https://min.io/docs/minio/linux/reference/minio-mc.html

## Connecting to the Filer
To connect to your filer, you will need the following, the URL, the ACCESS KEY, and the SECRET KEY. All of these can be found in a secret in your namespace.

You will have a secret for each filer and share you have access to. You can view this by executing `kubectl get secrets -ns $NB_NAMESPACE`
NB_NAMESPACE is an environment variable that contains your notebook namespace

This will produce a list of secrets. Your filer related secrets should look something like;
`fld9filer-conn-secret`

Now that you know which secret you want, you can get the values needed by executing
`S3_URL=$(kubectl get secret fld9filer-conn-secret -n $NB_NAMESPACE -o jsonpath='{.data.S3_URL}' | base64 --decode)`
`S3_ACCESS=$(kubectl get secret fld9filer-conn-secret -n $NB_NAMESPACE -o jsonpath='{.data.S3_ACCESS}' | base64 --decode)`
`S3_SECRET=$(kubectl get secret fld9filer-conn-secret -n $NB_NAMESPACE -o jsonpath='{.data.S3_SECRET}' | base64 --decode)`

## Setting your bucket alias
You must create an alias for `mc` to use when referring to the bucket to perform actions.
Using the information from the previous step run the following in the terminal;
`mc alias $nameofChoice $S3_URL $S3_ACCESS $S3_SECRET` The $nameOfChoice is up to you, but I would suggest you choose the name of the filer or share at which this account was created.
In this case, the account will be created at the fld9filer level so my command looked like;
`mc alias fld9filer $S3_URL $S3_ACCESS $S3_SECRET`


## Copying files to and from the filer
Your command will look like a regular `cp` command where the first argument is SOURCE and the second is DESTINATION except with `mc` in front of it.
For example
`mc cp fld9filer/s3bucket/Q1/Samsung.txt ~/LocalSamsung.txt --insecure`
Will provide
```
jovyan@pat-jl-testing:~$ mc cp fld9filer/s3bucket/Q1/Samsung.txt ~/LocalSamsung.txt --insecure
...ca/s3bucket/Q1/Samsung.txt: 32 B / 32 B ┃▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓┃ 81 B/s 0s(base) jovyan@pat-jl-testing:~$ ls
LocalSamsung.txt  
```