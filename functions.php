<?php
// some helper functions

function encode( $data ){
    return base64_encode( $data );
}

function decode( $data ){
    return base64_decode( $data ); 
}