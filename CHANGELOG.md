### 2.1.0 / 2014-12-26

* Added `#perform_service` to `Ballast::Concerns::Common`.

### 2.0.1 / 2014-12-26

* Added `transport` parameter to `Ballast::Service#as_ajax_response`.

### 2.0.0 / 2014-11-02

#### General

* **Dropped compatibility for Ruby < 2.1**.
* Added `Ballast::AjaxResponse`.
* Added `Ballast::Emoji`.
* Added `Ballast::Service`.
* Added `Ballast::Service::Response`.
* Removed `Ballast::Context`.
* Removed `Ballast::Operation`.
* Removed `Ballast::OperationsChain`.

#### Ballast::Errors

* Renamed `Ballast::Errors::BaseError` to `Ballast::Errors::Base`.
* Renamed `Ballast::Errors::PerformError` to `Ballast::Errors::Failure`.
* Renamed `Ballast::Errors::ValidationError` to `Ballast::Errors::ValidationFailure`.
* Renamed attribute `response` to `details` in `Ballast::Errors::Base`.

#### Ballast::Configuration

* Added `Ballast::Configuration#default_root`.
* Added `Ballast::Configuration#default_environment`.
* Changed interface of `Ballast::Configuration#initialize`.

#### Ballast::Concerns::AjaxHandling (formerly Ballast::Concerns::Ajax)

* Renamed `Ballast::Concerns::Ajax` to `Ballast::Concerns::AjaxHandling`
* Renamed `Ballast::Concerns::AjaxHandling#is_ajax_request?` to `Ballast::Concerns::AjaxHandling#ajax_request?`.
* Renamed `Ballast::Concerns::AjaxHandling#prepare_ajax` to `Ballast::Concerns::AjaxHandling#prepare_ajax_response` and changed its interface.
* Move responsibility of `Ballast::Concerns::AjaxHandling#send_ajax` to `Ballast::AjaxResponse#send`.
* Move responsibility of `Ballast::Concerns::AjaxHandling#update_ajax` to `Ballast::AjaxResponse#import_from_service`.
* Changed interface of `Ballast::Concerns::AjaxHandling#generate_robots_txt`.

#### Ballast::Concerns::Common

* Renamed `Ballast::Concerns::Common#is_json?` to `Ballast::Concerns::Common#json?`.
* Renamed `Ballast::Concerns::Common#sending_data?` to `Ballast::Concerns::Common#request_data?`.
* Changed interface of `Ballast::Concerns::Common#format_short_duration`.
* Changed interface of `Ballast::Concerns::Common#format_short_amount`.
* Changed interface of `Ballast::Concerns::Common#format_long_date`.
* Changed interface of `Ballast::Concerns::Common#authenticate_user`.

#### Ballast::Concerns::ErrorsHandling

* Changed interface of `Ballast::Concerns::ErrorsHandling#handle_error`.
* `Ballast::Concerns::ErrorsHandling::handle_error` now sets only one variable, `@error`, which contains the previous version variables and embeds the exception.

#### Ballast::Concerns::View

* Renamed `Ballast::Concerns::View#set_layout_params` to `Ballast::Concerns::View#update_layout_params`.
* Renamed `Ballast::Concerns::View#add_javascript_params` to `Ballast::Concerns::View#update_javascript_params` and changed its interface.
* Changed interface of `Ballast::Concerns::View#browser_supported?`.
* Changed interface of `Ballast::Concerns::View#javascript_params`.

### 1.9.3 / 2014-03-15

* Added `Ballast::Concerns::Ajax#generate_robots_txt`.

### 1.9.2 / 2014-03-09

* Fixed type for HTML in `Ballast::Concerns::ErrorsHandling#handle_error`.

### 1.9.1 / 2014-03-08

* `Ballast::Configuration` now makes sure file with dashes are accessible in the dotted notation.

### 1.9.0 / 2014-02-16

* Added `start_reactor` to `Ballast.in_em_thread`.

### 1.8.0 / 2014-01-29

* Added `Ballast.in_em_thread`.

### 1.7.0 / 2014-01-25

* Added `Ballast::Concerns::View#set_layout_params`.
* Added `Ballast::Concerns::View#layout_params`.
* Added `Ballast::Concerns::View#layout_param`.

### 1.6.0 / 2014-01-25

* `Ballast::Concerns::Ajax#allow_cors`'s parameters are now customizable.
* Added `Ballast::Concerns::Common#perform_operations_chain`.
* Fixed `Ballast::OperationsChain` behavior.

### 1.5.3 / 2014-01-04

* Do not join backtrace in errors.

### 1.5.2 / 2014-01-04

* Improved pretty JSON handling.

### 1.5.1 / 2014-01-04

* Fixed is_json? detection.

### 1.5.0 / 2014-01-04

* Added is_json? to `Ballast::Concerns::Common`.

### 1.4.0 / 2014-01-04

* Added format parameter to `Ballast::ErrorsHandling#handle_error`.

### 1.3.0 / 2013-12-30

* Added ApplicationConfiguration class.

### 1.2.0 / 2013-12-25

* Changed Javascript parameters output interface.

### 1.1.2 / 2013-12-25

* Made `Ballast::Concerns::Common#format_short_amount`'s second parameter optional.

### 1.1.1 / 2013-12-25

* Fixed authentication error handling.

### 1.1.0 / 2013-12-25

* Added domain handling.

### 1.0.0 / 2013-12-25

* Initial version.
