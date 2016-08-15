
Serving BAM files for IGV view
==============================

If given access to BAM files, Varapp allows users to see the read alignments 
at the origin of the variants calls, directly in the app's window, 
thanks to `IGV.js <https://github.com/igvteam/igv.js/tree/master>`_.

Since BAM files are typically big, they will not be stored on the client's
machine. Since for human data they are very sensible, they should not be downloadable
directly. There should be some sort of authentication.

Here is how we implemented it in Varapp:

* The `bam` table of Varapp's users db defines a correspondance between samples
  (database id + sample name) and a secret random `key`.
* In the database of some file server application, the same secret `key` corresponds 
  to the path of a BAM file on disk. 
* When accessed with e.g. `https://<hostname>/bamserver/<key>`,
  the file server application returns (part of) the content of the BAM file.
  It must accept the Range HTTP header.
* For each sample to view, IGV.js must be given a URL to the BAM file.
  We give it `https://<hostname>/bamserver/<key>`.
  It queries the BAM index to know the range of bytes corresponding
  to the genomic region to display. Then it makes Range requests to
  extract these bytes.

Such a very simple BAM server can be found here: 
`<https://github.com/jdelafon/bam-server-scala>`_
and set up easily.

You can write your own, as long as the `key` field of the `bam` table
for a sample used to build a URL `https://.../<key>` returns the corresponding
BAM file's content (`key` could be anything). 
Range headers must be supported (configure CORS if needed).


