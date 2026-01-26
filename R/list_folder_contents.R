#' List Folder Contents
#'
#' Returns the json listing of a CEDA folder at a given URL
#'
#' @param url url (inclusive of "https://data.ceda.ac.uk") of folder to list
#'
#' @author W. S. Drysdale
#'
#' @export

list_folder_contents = function(url){
  jsonlite::fromJSON(paste0(url,"?json"))$items |>
    tibble::as_tibble()

}
