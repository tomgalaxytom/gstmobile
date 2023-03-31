<?php
namespace App\System\Secure;

/**
 * encryption using Sha
 */

 class Encrypt {
    /**
     * Encrypt string
     *
     * @param  $string
     * @return $encryptedString
     */
    public function encrypt($string)
    {
        $config = new \App\System\Config();
        $privateKey       = $config->get('encrypt_private_key') ;
        $secretKey        =  $config->get('encrypt_secret_key');
        $encryptMethod      = "AES-256-CBC";
        $key = substr(hash('sha256', $privateKey), 0, 32);
        $ivalue = substr(hash('sha256', $secretKey), 0, 16); // sha256 is hash_hmac_algo
        $encryptedString = openssl_encrypt($string, $encryptMethod, $key, 0, $ivalue);
        return $encryptedString;  // output is a encrypted value
    }

    /**
     * Decrypt from sha encrypted string
     *
     * @param string $stringEncrypt
     * @return string $decryptedString
     */
    public function decrypt($stringEncrypt)
    {
        $config = new \App\System\Config();
        $privateKey       = $config->get('encrypt_private_key') ;
        $secretKey        =  $config->get('encrypt_secret_key');
        $encryptMethod    = "AES-256-CBC";

        $key = substr(hash('sha256', $privateKey), 0, 32);
        $ivalue = substr(hash('sha256', $secretKey), 0, 16); // sha256 is hash_hmac_algo

        $decryptedString = openssl_decrypt($stringEncrypt, $encryptMethod, $key, 0, $ivalue);

        return $decryptedString;
    }
 }
