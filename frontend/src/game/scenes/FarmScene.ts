import { TileMap, TILE_SIZE } from '../TileMap';

export async function createFarmScene(): Promise<TileMap> {
  const tileMap = new TileMap();
  await tileMap.loadFromTiled('/tiny-nong/Tilemap/map.json');
  return tileMap;
}

export { TILE_SIZE };
