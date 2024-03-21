Welcome! These are instructions to connect to your filer.
To connect to the filer we make use of the minio client as seen here https://min.io/docs/minio/linux/reference/minio-mc.html

## Connecting to the Filer
To connect to your filer, you will need the following, the URL, the ACCESS KEY, and the SECRET KEY. All of these can be found in a secret in your namespace.

You will have a secret for each filer you have access to. You can view this by executing `kubectl get secrets -ns ${YOUR_NAMESPACE}`
To find out what your namespace is, look in the address bar
If you are in a notebook it should be the value after `notebook` and before the name of your notebook.
Example: notebook/namespace-here/jose-notebook/lab

This will produce a list of secrets. Your filer related secrets should look something like;
`fld9filer-conn-secret`

Now that you know which secret you want, you can get the values needed by executing
`kubectl get secret fld9filer-conn-secret -n ${YOUR_NAMESPACE} -o jsonpath='{.data.S3_URL} | base64 --decode`
`kubectl get secret fld9filer-conn-secret -n ${YOUR_NAMESPACE} -o jsonpath='{.data.S3_ACCESS} | base64 --decode`
`kubectl get secret fld9filer-conn-secret -n ${YOUR_NAMESPACE} -o jsonpath='{.data.S3_SECRET} | base64 --decode`

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