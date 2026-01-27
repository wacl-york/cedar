#' CEDA Access Token
#'
#' Return an exiting access token, or generate a fresh one
#' Tokens are stored in the local environment, along with their expiry datetime
#' If a token expires within an hour, or cannot be found, a new one is requested
#' from the \code{ceda_url_token()} using the username and password provided
#'
#' @param user CEDA username
#' @param pass CEDA password
#' @param force should a new token be requested, even if the current one hasn't expired? Default FALSE
#' @param suppressError stops the function erroring when a status other than 200 is returned.
#'        used by \code{ceda_status()}. Default FALSE
#'
#' @export
#'
#' @author W. S. Drysdale

ceda_token = function(user, pass, force = FALSE, suppressError = FALSE){

  system_time_utc_plus_1_hour = lubridate::with_tz(Sys.time(), "UTC")+3600

  if(force){
    the$access_token = NULL
    the$access_token_expires = NULL
    the$access_token_response = NULL
  }

  # if access token exists
  if(!is.null(the$access_token)){
    # and if access token has not expired, or does not expire in the next hour
    if(the$access_token_expires > system_time_utc_plus_1_hour)
      return(the$access_token)
  }

  # if token has expired / doesn't exist or we are doing a force refresh

  req = httr2::request(ceda_url_token()) |>
    httr2::req_method("POST") |>
    httr2::req_auth_basic(
      user = user,
      password = pass
    ) |>
    httr2::req_error(is_error = \(resp) FALSE) # we handle the error ourselves later

  the$access_token_response = httr2::req_perform(req)
  the$access_token_time_of_last_request = lubridate::with_tz(Sys.time(), "UTC")

  if(the$access_token_response$status_code == 200){
    token = the$access_token_response$body |>
      rawToChar() |>
      jsonlite::parse_json()

    the$access_token = token$access_token
    the$access_token_expires = as.POSIXct(token$expires, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")

    # Return
    return(the$access_token)
  }else{
    if(!suppressError){
      stop(paste0("Token request returned status ", the$access_token_response$status_code, ": ", httr2::resp_status_desc(the$access_token_response)))
    }
  }
}
