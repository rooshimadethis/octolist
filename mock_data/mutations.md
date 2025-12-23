# Future Mutations

These are the GraphQL mutations we plan to implement for user tracking and library management.

## 1. Upgrade/Update List Entry (`SaveMediaListEntry`)

This is the main mutation for:
*   Adding a show to your list.
*   Moving a show between lists (Planning -> Watching).
*   Updating progress (Episode 1 -> 2).
*   Scoring a show.

```graphql
mutation SaveMediaListEntry(
  $id: Int, 
  $mediaId: Int, 
  $status: MediaListStatus, 
  $score: Float, 
  $progress: Int, 
  $startedAt: FuzzyDateInput, 
  $completedAt: FuzzyDateInput
) {
  SaveMediaListEntry(
    id: $id, 
    mediaId: $mediaId, 
    status: $status, 
    score: $score, 
    progress: $progress, 
    startedAt: $startedAt, 
    completedAt: $completedAt
  ) {
    id
    status
    score
    progress
    startedAt { year month day }
    completedAt { year month day }
  }
}
```

## 2. Remove from Library (`DeleteMediaListEntry`)

Used to completely remove an entry from the user's library.

```graphql
mutation DeleteMediaListEntry($id: Int) {
  DeleteMediaListEntry(id: $id) {
    deleted
  }
}
```
