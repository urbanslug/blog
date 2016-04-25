import Graphics.Rendering.Chart
import Graphics.Rendering.Chart.Backend.Cairo
import Data.Colour
import Data.Colour.Names
import Data.Default.Class
import Control.Lens
import System.Environment(getArgs)

chart borders = toRenderable layout
 where
  layout = 
        layout_title .~ "Comparison of Africa - Europe power consumption" ++ btitle
      $ layout_title_style . font_size .~ 20
      $ layout_x_axis . laxis_generate .~ autoIndexAxis alabels
      $ layout_y_axis . laxis_title .~ "billion kW h/yr"
      $ layout_left_axis_visibility . axis_show_ticks .~ True
      $ layout_plots .~ [ plotBars bars2 ]
      $ def :: Layout PlotIndex Double

  bars2 = plot_bars_titles .~ ["Europe Power Consumption"
                              , "15% of Europe Power Consumption"
                              , "Africa Power Consumption"
                              , "(Africa P. C.)+(15% Europe P.C.)"]
          
      $ plot_bars_values .~ addIndexes [[3409], [0, 511.3], [0,0,559.6], [0,0,0,1071]]
      $ plot_bars_style .~ BarsStacked
      $ plot_bars_spacing .~ BarsFixWidth 30
      $ plot_bars_item_styles .~ map mkstyle (cycle defaultColorSeq)
      $ def

  alabels = ["E.P.C.", "15% of E.P.C.", "A.P.C.", "(A.P.C.)+(15% of E.P.C.)"]


  btitle = if borders then "" else " (no borders)"
  bstyle = if borders then Just (solidLine 1.0 $ opaque black) else Nothing
  mkstyle c = (solidFillStyle c, bstyle)

main = renderableToFile def (chart True) "example11_big.png"
