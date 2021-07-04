defmodule Example.Scene.Transforms do
  use Scenic.Scene
  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  alias Example.Component.Nav
  alias Example.Component.Notes

  @notes """
    \"Transforms\" demonstrates using transforms to position, rotate and scale.
    The upper sliders apply transforms to the group containing the inset UI.
    The lower slider rotates the quad independantly of the upper sliders.
  """

  @start_x 150
  @start_y 300
  @start_scale 1.0

  @graph Graph.build(font: :roboto, font_size: 20)
         |> group(
           fn g ->
             g
             |> group(
               fn g ->
                 g
                 |> text("X")
                 |> text("Y", translate: {0, 20})
                 |> text("Scale", translate: {0, 40})
                 |> text("Angle", translate: {0, 60})
               end,
               translate: {60, 20},
               text_align: :right
             )
             |> group(
               fn g ->
                 g
                 |> slider({{00, 500}, @start_x}, id: :pos_x)
                 |> slider({{180, 400}, @start_y}, id: :pos_y, translate: {0, 20})
                 |> slider({{0.2, 3.0}, @start_scale}, id: :scale, translate: {0, 40})
                 |> slider({{-1.5708, 1.5708}, 0}, id: :rotate_ui, translate: {0, 60})
               end,
               translate: {70, 6}
             )
           end,
           translate: {0, 70}
         )
         |> group(
           fn g ->
             g
             |> text("Inner UI group", translate: {0, 30})
             |> quad({{0, 20}, {30, 0}, {36, 26}, {25, 40}},
               id: :quad,
               fill: {:linear, {0, 0, 40, 40, :yellow, :purple}},
               stroke: {2, :khaki},
               # pin: {400,310}
               translate: {140, 0},
               scale: 1.4
             )
             |> slider({{-1.5708, 1.5708}, 0}, id: :rotate_quad, translate: {0, 50}, width: 200)
           end,
           translate: {@start_x, @start_y},
           pin: {100, 25},
           id: :ui_group
         )

         # Nav and Notes are added last so that they draw on top
         |> Nav.add_to_graph(__MODULE__)
         |> Notes.add_to_graph(@notes)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  def init(scene, _param, _opts) do
    graph = @graph

    scene =
      scene
      |> push_graph(graph)
      |> assign(
        graph: graph,
        x: @start_x,
        y: @start_y
      )

    {:ok, scene}
  end

  # --------------------------------------------------------
  def handle_event({:value_changed, :pos_x, x}, _, %{assigns: %{graph: graph, y: y}} = scene) do
    graph = Graph.modify(graph, :ui_group, &update_opts(&1, translate: {x, y}))
    scene = push_graph(scene, graph)
    {:halt, assign(scene, graph: graph, x: x)}
  end

  # --------------------------------------------------------
  def handle_event({:value_changed, :pos_y, y}, _, %{assigns: %{graph: graph, x: x}} = scene) do
    graph = Graph.modify(graph, :ui_group, &update_opts(&1, translate: {x, y}))
    scene = push_graph(scene, graph)
    {:halt, assign(scene, graph: graph, y: y)}
  end

  # --------------------------------------------------------
  def handle_event({:value_changed, :scale, scale}, _, %{assigns: %{graph: graph}} = scene) do
    graph = Graph.modify(graph, :ui_group, &update_opts(&1, scale: scale))
    scene = push_graph(scene, graph)
    {:halt, assign(scene, graph: graph)}
  end

  # --------------------------------------------------------
  def handle_event({:value_changed, :rotate_ui, angle}, _, %{assigns: %{graph: graph}} = scene) do
    graph = Graph.modify(graph, :ui_group, &update_opts(&1, rotate: angle))
    scene = push_graph(scene, graph)
    {:halt, assign(scene, graph: graph)}
  end

  # --------------------------------------------------------
  def handle_event({:value_changed, :rotate_quad, angle}, _, %{assigns: %{graph: graph}} = scene) do
    graph = Graph.modify(graph, :quad, &update_opts(&1, rotate: angle))
    scene = push_graph(scene, graph)
    {:halt, assign(scene, graph: graph)}
  end
end
