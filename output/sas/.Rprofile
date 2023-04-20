# Set Personal Package Directory
#-------------------------------
home_dir <- Sys.getenv("HOME")
package_dir <- paste0(home_dir, "/R/", "r-packages-", R.Version()$major, ".", R.Version()$minor)
dir.create(package_dir, recursive = T, showWarnings = F)
.libPaths(new = package_dir)
# Clean up
rm(home_dir)
rm(package_dir)

# Add any customizations below
#-----------------------------
#options(stringsAsFactors = FALSE)
#options(prompt = "AAW> ")
