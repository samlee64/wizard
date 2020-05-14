import {Pagination } from './utils'

export interface GifMetadata {
  id: string;
  tags: string[];
  "File Name": string;
}

export interface Gif {
  id: string;
  fileName: string;
}

interface Queryable {
  tags: string[] | undefined;
}

export interface GifQuery extends Queryable, Pagination {}
