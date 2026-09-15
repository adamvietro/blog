defmodule Blog.Accounts.UserNotifierTest do
  use Blog.DataCase, async: true

  alias Blog.Accounts.UserNotifier
  alias Blog.AccountsFixtures

  setup do
    %{user: AccountsFixtures.user_fixture()}
  end

  test "confirmation instructions are sent from the verified blog domain", %{user: user} do
    {:ok, email} = UserNotifier.deliver_confirmation_instructions(user, "https://example.com/confirm")

    assert email.from == {"Adam's Blog", "noreply@adamsites.com"}
    assert email.to == [{"", user.email}]
  end

  test "reset password instructions are sent from the verified blog domain", %{user: user} do
    {:ok, email} =
      UserNotifier.deliver_reset_password_instructions(user, "https://example.com/reset")

    assert email.from == {"Adam's Blog", "noreply@adamsites.com"}
  end

  test "update email instructions are sent from the verified blog domain", %{user: user} do
    {:ok, email} = UserNotifier.deliver_update_email_instructions(user, "https://example.com/update")

    assert email.from == {"Adam's Blog", "noreply@adamsites.com"}
  end
end
