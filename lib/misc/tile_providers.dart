import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate:
          'https://tile.tracestrack.com/topo_en/{z}/{x}/{y}.png?key=551c35c11d2a5300f4a7bcf8a55b50ac',
      tileProvider: CancellableNetworkTileProvider(),
    );
