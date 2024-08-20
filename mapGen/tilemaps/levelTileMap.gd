extends TileMap
class_name LevelTileMap

var atlasId := 0

var tileMapFloorVector : Vector2i

var tileMapFloorVectorTrapNE : Vector2i
var tileMapFloorVectorTrapNW : Vector2i
var tileMapFloorVectorTrapSE : Vector2i
var tileMapFloorVectorTrapSW : Vector2i

var tileMapFloorVectorClawNE : Vector2i
var tileMapFloorVectorClawNW : Vector2i
var tileMapFloorVectorClawSE : Vector2i
var tileMapFloorVectorClawSW : Vector2i

var tileMapFloorVectorTubeNE : Vector2i
var tileMapFloorVectorTubeNW : Vector2i
var tileMapFloorVectorTubeSE : Vector2i
var tileMapFloorVectorTubeSW : Vector2i

var tileMapWallVector : Vector2i
var tileMapCornerVector : Vector2i

var tileMapTopAlt : int
var tileMapBottomAlt : int
var tileMapLeftAlt : int
var tileMapRightAlt : int

var tileMapTRAlt : int
var tileMapTLAlt : int
var tileMapBLAlt : int
var tileMapBRAlt : int


func setAtlasIdAndVectors(id : int):
	atlasId = id
	
	#lab
	if id == 0:
		tileMapFloorVector = Vector2i(0, 8)

		tileMapFloorVectorTrapNE = Vector2i(0, 6)
		tileMapFloorVectorTrapNW = Vector2i(1, 6)
		tileMapFloorVectorTrapSE = Vector2i(0, 7)
		tileMapFloorVectorTrapSW = Vector2i(1, 7)

		tileMapFloorVectorClawNE = Vector2i(0, 4)
		tileMapFloorVectorClawNW = Vector2i(1, 4)
		tileMapFloorVectorClawSE = Vector2i(0, 5)
		tileMapFloorVectorClawSW = Vector2i(1, 5)

		tileMapFloorVectorTubeNE = Vector2i(2, 4)
		tileMapFloorVectorTubeNW = Vector2i(3, 4)
		tileMapFloorVectorTubeSE = Vector2i(2, 5)
		tileMapFloorVectorTubeSW = Vector2i(3, 5)

		tileMapWallVector = Vector2i(0, 0)
		tileMapCornerVector = Vector2i(5, 0)

		tileMapTopAlt = 0
		tileMapBottomAlt = 1
		tileMapLeftAlt = 2
		tileMapRightAlt = 3

		tileMapTRAlt = 0
		tileMapTLAlt = 5
		tileMapBLAlt = 6
		tileMapBRAlt = 7

	#farm
	if id == 1:
		tileMapFloorVector = Vector2i(0, 0)

		tileMapFloorVectorTrapNE = Vector2i(4, 5)
		tileMapFloorVectorTrapNW = Vector2i(5, 5)
		tileMapFloorVectorTrapSE = Vector2i(4, 6)
		tileMapFloorVectorTrapSW = Vector2i(5, 6)

		tileMapFloorVectorClawNE = Vector2i(0, 5)
		tileMapFloorVectorClawNW = Vector2i(0, 6)
		tileMapFloorVectorClawSE = Vector2i(1, 5)
		tileMapFloorVectorClawSW = Vector2i(1, 6)

		tileMapFloorVectorTubeNE = Vector2i(0, 7)
		tileMapFloorVectorTubeNW = Vector2i(1, 7)
		tileMapFloorVectorTubeSE = Vector2i(2, 6)
		tileMapFloorVectorTubeSW = Vector2i(1, 8)

		tileMapWallVector = Vector2i(0, 8)
		tileMapCornerVector = Vector2i(0, 8)

		tileMapTopAlt = 0
		tileMapBottomAlt = 0 #1
		tileMapLeftAlt = 0 #2
		tileMapRightAlt = 0 #3

		tileMapTRAlt = 0
		tileMapTLAlt = 0 #5
		tileMapBLAlt = 0 #6
		tileMapBRAlt = 0 #7
	
	#dungeon/sewer
	if id == 2:
		tileMapFloorVector = Vector2i(0, 8)

		tileMapFloorVectorTrapNE = Vector2i(0, 8)
		tileMapFloorVectorTrapNW = Vector2i(0, 8)
		tileMapFloorVectorTrapSE = Vector2i(0, 8)
		tileMapFloorVectorTrapSW = Vector2i(0, 8)

		tileMapFloorVectorClawNE = Vector2i(0, 8)
		tileMapFloorVectorClawNW = Vector2i(0, 8)
		tileMapFloorVectorClawSE = Vector2i(0, 8)
		tileMapFloorVectorClawSW = Vector2i(0, 8)

		tileMapFloorVectorTubeNE = Vector2i(0, 8)
		tileMapFloorVectorTubeNW = Vector2i(0, 8)
		tileMapFloorVectorTubeSE = Vector2i(0, 8)
		tileMapFloorVectorTubeSW = Vector2i(0, 8)

		tileMapWallVector = Vector2i(0, 0)
		tileMapCornerVector = Vector2i(5, 0)

		tileMapTopAlt = 0
		tileMapBottomAlt = 1
		tileMapLeftAlt = 2
		tileMapRightAlt = 3

		tileMapTRAlt = 0
		tileMapTLAlt = 1
		tileMapBLAlt = 2
		tileMapBRAlt = 3
