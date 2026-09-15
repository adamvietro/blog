defmodule BlogWeb.CoreComponentsTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias BlogWeb.CoreComponents

  describe "error/1" do
    test "renders the given message with an icon" do
      html =
        render_component(&CoreComponents.error/1,
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "can't be blank" end}]
        )

      assert html =~ "can&#39;t be blank"
    end
  end

  describe "list/1" do
    test "renders each item's title and content" do
      html =
        render_component(&CoreComponents.list/1,
          item: [
            %{__slot__: :item, inner_block: fn _, _ -> "Elixir" end, title: "Tag"}
          ]
        )

      assert html =~ "Tag"
      assert html =~ "Elixir"
    end
  end

  describe "table/1" do
    test "renders a row per item with each column's content" do
      html =
        render_component(&CoreComponents.table/1,
          id: "things",
          rows: [%{name: "First"}, %{name: "Second"}],
          col: [
            %{__slot__: :col, inner_block: fn _, row -> row.name end, label: "Name"}
          ]
        )

      assert html =~ "Name"
      assert html =~ "First"
      assert html =~ "Second"
    end
  end

  describe "back/1" do
    test "renders a link to the given path with the inner content" do
      html =
        render_component(&CoreComponents.back/1,
          navigate: "/posts",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Back to posts" end}]
        )

      assert html =~ "Back to posts"
      assert html =~ ~s(href="/posts")
    end
  end

  describe "icon/1" do
    test "renders a span with the hero- class name" do
      html = render_component(&CoreComponents.icon/1, name: "hero-x-mark-solid")

      assert html =~ "hero-x-mark-solid"
    end
  end

  describe "modal/1" do
    test "renders the modal container and its content, hidden by default" do
      html =
        render_component(&CoreComponents.modal/1,
          id: "test-modal",
          inner_block: [%{__slot__: :inner_block, inner_block: fn _, _ -> "Modal content" end}]
        )

      assert html =~ "Modal content"
      assert html =~ ~s(id="test-modal")
      assert html =~ "hidden"
    end
  end

  describe "JS command helpers" do
    test "show/2 builds a JS command targeting the given selector" do
      js = CoreComponents.show("#some-id")
      assert %Phoenix.LiveView.JS{ops: [["show" | _]]} = js
    end

    test "hide/2 builds a JS command targeting the given selector" do
      js = CoreComponents.hide("#some-id")
      assert %Phoenix.LiveView.JS{ops: [["hide" | _]]} = js
    end

    test "show_modal/2 chains show commands and focuses the modal content" do
      js = CoreComponents.show_modal("my-modal")
      op_names = Enum.map(js.ops, &List.first/1)

      assert "show" in op_names
      assert "add_class" in op_names
      assert "focus_first" in op_names
    end

    test "hide_modal/2 chains hide commands" do
      js = CoreComponents.hide_modal("my-modal")
      op_names = Enum.map(js.ops, &List.first/1)

      assert "hide" in op_names
      assert "remove_class" in op_names
    end
  end
end
