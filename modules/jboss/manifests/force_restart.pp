define jboss::force_restart() {
   info("Brutally murdering JBoss processes and forcing a restart")
   exec { "force-jboss-restart":
    command => "service jboss restart",
    path => [ "/bin", "/usr/bin" ],
  }
}
