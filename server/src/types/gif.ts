export interface GifMetadata {
  id: string;
  tags: string[];
  "File Name": string;
}

export interface Gif {
  id: string;
  fileName: string;
}

export interface Queryable {
  tags: string[];
  id: string;
}

export interface GifQuery extends Partial<Queryable> {
  page: number;
}
