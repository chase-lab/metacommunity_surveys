# wright_2021
if (!file.exists("./data/raw data/wright_2021/SEVBeeData2002-2019.csv")) {
  dir.create(path = "./data/raw data/wright_2021", showWarnings = FALSE)
  curl::curl_download(
    url = "https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-sev.321.2&entityid=6ecbc1384da24a08263a85b148807831",
    destfile = "./data/raw data/wright_2021/SEVBeeData2002-2019.csv"
  )
}

if (!file.exists("./data/raw data/wright_2021/SEVBeeSpeciesList2002-2019.csv")) {
  dir.create(path = "./data/raw data/wright_2021", showWarnings = FALSE)
  curl::curl_download(
    url = "https://portal.edirepository.org/nis/dataviewer?packageid=knb-lter-sev.321.2&entityid=4a6e8590c214c32921832a71264ca195",
    destfile = "./data/raw data/wright_2021/SEVBeeSpeciesList2002-2019.csv"
  )
}
