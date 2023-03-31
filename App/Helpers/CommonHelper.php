<?php
namespace App\Helpers;

use App\System\Log;

/**
 * Common helper file for some operations
 */
class CommonHelper {
    static $allowedImageTypes =  array('jpg','png','jpeg','gif','pdf');
    static $allowedBillMimeTypes =  array('image/jpg','image/png','image/jpeg','application/pdf');
    static $allowedImageMimeTypes =  array('image/jpg','image/png','image/jpeg');
    public static function getFileMimeType($filePathOrString, $encoded = false){
        if( $encoded ){
            if( function_exists('finfo_open')){
                $fileInfoHandler = finfo_open();
                $fileMimeType = finfo_buffer($fileInfoHandler, $filePathOrString, FILEINFO_MIME_TYPE);
            } else {
                $tempPath = sys_get_temp_dir();
                $tempFileName = md5(time());
                $tempFilePath = $tempPath . DIRECTORY_SEPARATOR . $tempFileName . ".png";
                self::saveFile($filePathOrString, $tempFilePath);
                $fileMimeType = mime_content_type($tempFilePath);
                unlink( $tempFilePath );
            }
        } else {
            $fileMimeType = mime_content_type($filePathOrString);
        }
        return $fileMimeType;
    }
    /**
     * get file size in kb, mb, etc
     *
     * @param $filePath
     * @param $foramt [b, kb, mb, gb, tb]
     * @param bool $raw [if its false, it just sends the number without suffix like KB, MB, etc]
     * @return string $fileSize
     */
    // public static function getFileSize($filePath, $raw = false, $format = 'b'){
    //     // just to make sure the format is always in lower case 
    //     $format = strtolower( $format );
    //     $fileSize = filesize($filePath);
    //     $multiplier = 0;
    //     switch( $format ){
    //         case 'kb':
    //             $multiplier = 1;
    //             break;
    //         case 'mb':
    //             $multiplier = 2;
    //             break;
    //         case 'gb':
    //             $multiplier = 3;
    //             break;
                
    //     }
    //     $fileSize = $fileSize / pow(1024, $multiplier);
    //     if( $raw == true ){
    //         return $fileSize ;
    //     } else {
    //         return $fileSize  . " ". $format;
    //     }
       
    // }

    
public static function getFileSize($filePath, $raw = false, $format = 'b'){
    $size = filesize($filePath);
    $units = array(
        'B',
        'KB',
        'MB',
        'GB',
        'TB',
        'PB',
        'EB',
        'ZB',
        'YB'
    );
    $power = $size > 0 ? floor(log($size, 1024)) : 0;
    return number_format($size / pow(1024, $power) , 2, '.', ',') . ' ' . $units[$power];
}

    /**
     * check if the bill type is allowed to upload
     * * @since 1.0
     * @author Stalin thomas
     * @param string $billPbillPathOrStringath
     * @param bool $encoded [if its true then the @param1 is string]
     * @return bool
     */
    public static function isValidBill($billPathOrString, $encoded = false ){
        $billMimeType = self::getFileMimeType( $billPathOrString, $encoded );
        return in_array( $billMimeType, self::$allowedBillMimeTypes );

    }
    
    /**
     * check if the image type is allowed to upload
     * @since 1.0
     * @author Stalin thomas
     * @param string $imagePathOrString
     * @param bool $encoded [if true, then the encoded string is provided in @param1]
     * @return bool
     */
    public static function isValidImage($imagePathOrString, $encoded =  false ){
        $imageMimeType = self::getFileMimeType( $imagePathOrString, $encoded );
        return in_array( $imageMimeType, self::$allowedBillMimeTypes );

    }

    /**
     * upload helper to upload files
     */
    public static function saveFile($fileContent, $destinationPath){   
        if( !is_dir( dirname($destinationPath)) ){
            Log::error('Directory not found ' . dirname($destinationPath));
        }  else {
            Log::info('Success');
            $fileHandler = fopen($destinationPath, 'wb' ); 
            fwrite($fileHandler, $fileContent);
            fclose($fileHandler); 
            Log::info( 'File succes written');
        }
        
    }
}