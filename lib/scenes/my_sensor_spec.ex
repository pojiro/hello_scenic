defmodule HelloScenic.Scene.MySensorSpec do
  use Scenic.Scene

  require Logger

  alias Scenic.Graph

  import Scenic.Primitives
  import Scenic.Components

  alias HelloScenic.Component.Nav
  alias HelloScenic.Component.Notes

  @body_offset 80
  @font_size 160

  @pubsub_data {Scenic.PubSub, :data}
  @pubsub_registered {Scenic.PubSub, :registered}

  @notes """
    \"Sensor\" is a simple scene that displays data from a simulated sensor.
  """

  @moduledoc """
  This version of `Sensor` illustrates using spec descriptions
  construct the display graph. Compare this with `Sensor` which uses
  anonymous functions.
  """

  @temperature text_spec("", id: :temperature, text_align: :center, font_size: @font_size)
  @humidity text_spec("", id: :humidity, text_align: :center, font_size: @font_size)

  @graph Graph.build(font: :roboto, font_size: 16)
         |> add_specs_to_graph(
           [
             @temperature,
             @humidity
           ],
           translate: {0, @body_offset}
         )
         # NavDrop and Notes are added last so that they draw on top
         |> Nav.add_to_graph(__MODULE__)
         |> Notes.add_to_graph(@notes)

  # ============================================================================
  # setup

  # --------------------------------------------------------
  @doc false
  @impl Scenic.Scene
  def init(scene, _param, _opts) do
    {width, _} = scene.viewport.size

    graph =
      @graph
      |> Graph.modify(:temperature, &update_opts(&1, translate: {width / 2, @font_size}))
      |> Graph.modify(:humidity, &update_opts(&1, translate: {width / 2, @font_size * 2}))

    Scenic.PubSub.subscribe(:aht20)

    scene =
      scene
      |> assign(:graph, graph)
      |> push_graph(graph)

    {:ok, scene}
  end

  @doc false
  @impl GenServer
  def handle_info({@pubsub_data, {:aht20, {t, h}, _}}, %{assigns: %{graph: graph}} = scene) do
    graph =
      graph
      |> Graph.modify(:temperature, &text(&1, "#{Float.round(t, 1)} °"))
      |> Graph.modify(:humidity, &text(&1, "#{Float.round(h, 1)} %"))

    scene =
      scene
      |> assign(graph: graph)
      |> push_graph(graph)

    {:noreply, scene}
  end

  def handle_info({@pubsub_registered, _}, scene) do
    {:noreply, scene}
  end
end
