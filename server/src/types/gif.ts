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
  tags: string[] | undefined;
  id: string | undefined;
}

export interface GifQuery extends Queryable {
  page: number;
}
