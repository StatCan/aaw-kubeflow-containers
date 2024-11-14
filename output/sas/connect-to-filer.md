Welcome! These are instructions to connect to your filer.

Your filer should be mounted to your notebook just like any other file system folder.
They will be located under your `home` directory of `~/home/jovyan` under the `filers` directory.
From there you will see a list of your filers and can then navitgate through them.

### Note for directories not specifically requested
If you do not request a directory you will not have access to it, unless it is under a directory you have requested.

For example, if you request fld9filer/test1/requested you will not see anything under filers/fld9filersvm/test1 **other** than the `requested` folder, but if there is a `fld9filer/test1/requested/randomFolder` you will be able to see `randomFolder`.

### Note for deleting a connected share
If you delete your connected share and then start up your notebook server again, you will not be connected to the filer anymore but you may still see a 'ghost' folder. This folder may say `fld9filersvm/s3test` but it will not be connected to the filer, and any data you write in that directory will get overwritten and deleted if you choose to re-add the previously connected share.


## Using the Command line
To connect to the filer we make use of the minio client as seen here https://min.io/docs/minio/linux/reference/minio-mc.html

For more detailed and intricacies with using your filer please refer to the documentation 
[here](https://zone.pages.cloud.statcan.ca/docs/en/5-Storage/FieldFilers.html)

## Connecting to the Filer
To interact with your filer, you will need the following:
- The ACCESS KEY
- The SECRET KEY
- The URL of the filer
- The BUCKET name

These values are all retrievable and visible via environment variables in your notebook. You can view them by executing `printenv | grep fldx` where `fldx` represents the filer whose information you want.
From there you can substitute the values into your mc command to create an alias for the filer.

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