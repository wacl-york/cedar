# cedar 

## Description 
`cedar` is an R package for interfacing with the [Centre for Environmental Data Analysis](https://www.ceda.ac.uk/)' (CEDA) data archive. It facilitates authentication via the [openDAP](https://help.ceda.ac.uk/article/4431-ceda-archive-web-download-and-services) endpoint, which requires authentication. Users can register for an account on the [CEDA website](https://services.ceda.ac.uk/cedasite/register/info/). It is not an official CEDA project and users should be familiarise themselves with the [guidance provided by CEDA](https://help.ceda.ac.uk/). 

## Install

```R
remotes::install_github("wacl-york/cedar")
```

## Data Download Prerequisite  
You will need to provide your credentials to `cedar::ceda_download()`. To avoid saving these credentials in your scripts, you can use the [keyring](https://cloud.r-project.org/web/packages/keyring/index.html) package to make use of your operating systems credential store.

>[!NOTE]
>At the time of writing the CEDA openDAP fails when passwords contain non-ascii characters. If you encounter issues, first try generating a [token manually](https://services-beta.ceda.ac.uk/account/token/). If you receive a 503 error, try changing your password to contain only alphanumeric characters and simple punctuation.


## Usage

### List Available Data

Data can be browsed [online](https://data.ceda.ac.uk/), once you have located your data set of interest you can import a list of files using the `list_folder_contents()` function, which collects the json data of the file structure as a tibble data frame, e.g.:

```R
url = "https://data.ceda.ac.uk/badc/osca/data/iop-1-summer"

cedar::list_folder_contents()
```

returns

```R
# A tibble: 6 × 16
  path                          directory name  last_modified fileset ext     size type  location content md5   last_audit download created regex_date phenomena
  <chr>                         <chr>     <chr> <chr>         <chr>   <chr>  <int> <chr> <chr>    <chr>   <chr> <chr>      <chr>    <chr>   <chr>      <list>   
1 /badc/osca/data/iop-1-summer… /badc/os… 00RE… 2024-03-09T0… spot-5… .txt  9.09e2 file  on_disk  "\nOSC… 7ece… 2025-10-1… https:/… NA      NA         <NULL>   
2 /badc/osca/data/iop-1-summer… /badc/os… lanc… 2023-04-04T1… spot-5… .csv  3.38e6 file  on_disk   NA     c1e1… 2025-08-1… https:/… 2023-0… 2021-06-15 <df>     
3 /badc/osca/data/iop-1-summer… /badc/os… york… 2023-04-04T1… spot-5… .csv  5.27e7 file  on_disk   NA     ca76… 2025-09-1… https:/… 2023-0… 2021-07-06 <df>     
4 /badc/osca/data/iop-1-summer… /badc/os… york… 2023-04-04T1… spot-5… .csv  1.39e8 file  on_disk   NA     b49f… 2025-10-1… https:/… 2023-0… 2021-07-07 <df>     
5 /badc/osca/data/iop-1-summer… /badc/os… york… 2025-03-11T1… spot-5… .csv  7.25e7 file  on_disk   NA     6f5f… NA         https:/… NA      2021-06-10 <df>     
6 /badc/osca/data/iop-1-summer… /badc/os… york… 2023-04-04T1… spot-5… .csv  6.58e7 file  on_disk   NA     3c26… 2025-09-1… https:/… 2023-0… 2021-07-07 <df>     

```

This data frame contains various metadata on the files, but crucially contains the openDAP download URL in the `download` column. This can be passed to `ceda_download()` along with your credentials to download a file:

```R
url = "https://data.ceda.ac.uk/badc/osca/data/iop-1-summer"

files = cedar::list_folder_contents(url)

cedar::ceda_download(
  url = files$download[2],
  fileOut = file.path("myproject", basename(files$path[2])),
  user = keyring::key_get("ceda_user"),
  pass = keyring::key_get("ceda_pass")
)
```