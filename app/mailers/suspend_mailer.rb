class SuspendMailer < ApplicationMailer
  def suspend_mail(user)
    @user = user
    mail(subject: 'アカウント凍結のお知らせ', to: @user.email)
  end
  
  def unsuspend_mail(user)
    @user = user
    mail(subject: 'アカウント凍結解除のお知らせ', to: @user.email)
  end
end
