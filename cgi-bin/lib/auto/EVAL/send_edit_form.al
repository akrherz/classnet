# NOTE: Derived from lib/EVAL.pm.  Changes made here will be lost.
package EVAL;

sub send_edit_form {
   my ($self,$query,$stu) = @_;
   my ($q_name,@q_names,$stud_ans);

   ERROR::print_error_header('Edit?');
   print "You may not view individual responses of a class evaluation.";
   CN_UTILS::print_cn_footer();
   exit(0);
}

1;
