#' CEDA Access Token
#'
#' Return an exiting access token, or generate a fresh one
#' Tokens are stored in the local environment, along with their expiry datetime
#' If a token expires within an hour, or cannot be found, a new one is requested
#' from the \code{ceda_url_token()} using the username and password provided
#'
#' @param user CEDA username
#' @param pass CEDA password
#'
#' @export
#'
#' @author W. S. Drysdale

ceda_token = function(user, pass){

  system_time_utc_plus_1_hour = lubridate::with_tz(Sys.time(), "UTC")+3600

  # if access token exists
  if(!is.null(the$access_token)){
    # and if access token has not expired, or does not expire in the next hour
    if(the$access_token_expires > system_time_utc_plus_1_hour)
      return(the$access_token)
  }

  # if token has expired or doesn't exist

  req = httr2::request(ceda_url_token()) |>
    httr2::req_method("POST") |>
    httr2::req_auth_basic(
      user = user,
      password = pass
    )

  resp = httr2::req_perform(req)

  if(resp$status_code != 200){
    stop(print("Token request returned status ", resp$status_code))
  }

  token = resp$body |>
    rawToChar() |>
    jsonlite::parse_json()

  the$access_token = token$access_token
  the$access_token_expires = as.POSIXct(token$expires, format = "%Y-%m-%dT%H:%M:%OSZ", tz = "UTC")

  # Return
  the$access_token

}
