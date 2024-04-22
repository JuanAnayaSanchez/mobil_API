<?php
    class APIResponse{
        public $code;
        public $message;
        public $data;

        public function __construct($code, $message, $data) {
            $this->code = $code;
            $this->message = $message;
            $this->data = $data;
        }
    
        // public function toJson() {
        //     return json_encode(array(
        //         'code' => $this->code,
        //         'message' => $this->message,
        //         'data' => $this->data
        //     ));
        // }
    }
?>