<?php
/**
 * api end point and corresponding class / method mapping
 */
use App\Api\User;
use App\Api\SampleApi;
use App\Api\StateApi;
use App\Api\BillApi;
return $routes = [
    'login'                      => [User::class, "login"],
    'logout'                     => [User::class, "logout"],
    'register'                   => [User::class, "register"],
    'get-user'                   => [User::class, "getUser"],
    'edit-username'              => [User::class, "editUserName"],
    'edit-mobilenumber'          => [User::class, "editPhoneNumber"],
    'already-mobilenumber-check' => [User::class, "alreadyPhoneNumberExists"],
    'edit-email'                 => [User::class, "editEmail"],
    'edit-district'              => [User::class, "editDistrictName"],
    'edit-pincode'               => [User::class, "editPincode"],
    'edit-address'               => [User::class, "editAddress"],
    'forgot-mpin'                => [User::class, "forgotMpin"],
    'change-password'            => [User::class, "changePassword"],
    'forgot-password'            => [User::class, "forgotPassword"],
    'send-otp'                   => [User::class, "submitOTP"],
    'set-mpin'                   => [User::class, "setMpin"],
    'save-profile'               => [User::class, "saveProfile"],
    'delete'                     => [User::class, "deleteUser"],
    'get-records'                => [SampleApi::class, 'getRecords'],
    'get-states'                 => [StateApi::class, 'getStates'],
    'get-districts'              => [StateApi::class, 'getDistricts'],
    'get-config-districts'       => [StateApi::class, 'getDistrictsConfig', array('config' => 'true')],
    'save-bill'                  => [BillApi::class, 'saveBill'],
    'get-invoices'               => [BillApi::class, 'getInvoices'],
    'get-invoices-history'       => [BillApi::class, 'getInvoicesHistory'],
    'get-invoices-daterange'     => [BillApi::class, 'getInvoicesbasedDateRange'],
    'get-awk-number'             => [BillApi::class, 'getAwkNumber'],
    'sample-api'                 => [SampleApi::class, 'test'],
    'bill-number-finalize'       => [BillApi::class, 'billNumberFinalize'],
    'start-end-date-picker'      => [BillApi::class, 'configBasedStartDateEndDate'],
    'get-invoice-count'          => [BillApi::class, 'getInvoiceCountBasedBillStartandEndDate']
    

];