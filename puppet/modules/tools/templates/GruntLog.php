<?php

/**
 * Class GruntLog
 */
class GruntLog
{
    /**
     * @var string
     */
    private $log;

    /**
     * @var string
     */
    private $content;

    /**
     * GruntLog constructor.
     * @param string $log
     */
    public function __construct($log = '/var/www/themes/grunt.log')
    {
        $this->log = $log;
    }

    /**
     * Generate output
     */
    public function output()
    {
        $this->read();
        $this->clean();
        $this->reverse();
        if (isset($_GET['content']) && $_GET['content'] === 'true') {
            echo $this->content;
        } else {
            echo /** @lang HTML */
                '<div id="content">' . $this->content . '</div><script>';
            echo /** @lang JavaScript */
            '   function reload() {
                    var xhr = new XMLHttpRequest();
                    xhr.onreadystatechange = function () {
                      if (xhr.readyState === 4) {
                        if (xhr.status === 200) {
                          document.getElementById("content").innerHTML = xhr.responseText;
                        }
                        setTimeout(function(){reload()}, 500);
                      }
                    };
                    xhr.open("GET", "GruntLog.php?content=true", true);
                    xhr.send();
                }
                reload();';
            echo /** @lang HTML */
            '</script><style>';
            echo /** @lang CSS */
            '*{font-family: monospace}';
            echo /** @lang HTML */
            '</style>';
        }
    }

    /**
     * Read Logfile
     */
    private function read()
    {
        if (file_exists($this->log)) {
            $this->content = file_get_contents($this->log);
        }
    }

    /**
     * Clean Logfile of shell
     */
    private function clean()
    {
        $this->content = htmlspecialchars($this->content);
        $this->content = preg_replace("/\\[\d{1,}m/", '', $this->content);
    }

    /**
     * Reverse order
     */
    private function reverse()
    {
        $content = explode("\n", $this->content);
        $content = array_reverse($content);
        $this->content = implode('<br />', $content);
    }
}

$log = new GruntLog();
$log->output();

