Wellcome, my hostname is: <?php echo $_SERVER['SERVER_ADDR']; ?>

Wait....
<?php 
  flush();
  ob_flush();
  sleep(10);
?>
Done!
