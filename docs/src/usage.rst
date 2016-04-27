
.. Non-breaking white space, to fill empty divs
.. |nbsp| unicode:: 0xA0
   :trim:

Users' manual
=============

.. figure:: /images/main-annot.png
   :width:  100%
   :alt: Main window

1.  Header section: database selection and account management.
2.  Samples selection summary. It shows the total number of selected samples.
    Clicking it brings to the :ref:`samples-selection` window.
3.  Filters panel: apply filters on the collection of variants (see below).
4.  Variants table: displays all variants passing the selected filters (see below).


.. _filters-panel:

Filters panel
-------------

.. container:: twocol

    .. container:: leftside

        A)  **Number of filtered variants** / total number of variants in the db.
        B)  **Reset filters** button.
        C)  **Location filter**. Supports chromosome coordinates such as 'chr1:100-200' and gene names.
            Multiple values can be entered, separated by commas. In this case, the query will return
            all variants in the *union* of all the regions.
        D)  **Filters**, grouped by categories. Click one category to unfold.
            Numbers in front of a filter show how many variants in the current selection
            would pass this filter. Sliders can be switched to text input with the small button on their right
            to enter more precise values if necessary.
        E)  **Filters summary**: shows the selected filters in a category even when the
            panel is closed. Click on the cross right to an item to quickly remove the filter.

    .. container:: rightside

        .. figure:: /images/filters-panel-annot.png
           :scale: 70%

.. container:: clear

    |nbsp|


.. _variants-table:

Variants table
--------------

.. figure:: /images/variants-table-annot.png
   :width:  100%
   :alt: Variants table

A) **Add/remove columns** of annotation.
B) **Export** the current variants selection to VCF, tabular text, or Annovar input format.
   The icon on the left of the button generates a report of all versions of the programs
   and databases used to call and annotate the variants.
C) **Create bookmarks** to save the state of your analysis with the leftmost button.
   Load a saved state with the middle one. Copy the current URL to clipboard with the rightmost
   one. See details about bookmarks below.
D) **Sort the values** by clicking on the table header's column names.
   Clicking once will sort in ascending order; click again for descending order.
   Not all columns can be sorted - the cursor changes when it is possible.
   Sorting can be a slow operation if there are too many variants.
E) **Table cells** can contain raw text, external links (the cursor changes to a curved arrow),
   links to open a 'lookup window' with more details (the cursor is a hand, see below), or can be shortened
   and display the full text when hovering the mouse (an ellipsis follows the text).
F) **Genotypes** for every selected sample are represented as colored squares. See details below.
G) The **Source** column only appears if the "compound het" scenario is selected, and indicates
   which of the parents is the source of the mutation.

Interpreting the genotypes
..........................

.. container:: twocol

    .. container:: leftside-sm

        .. figure:: /images/genotypes.png
           :scale: 90%

    .. container:: rightside-sm

        * Each variant has one such 'box' representing all selected samples.
        * Each column in a sample; each square is an allele.
        * There are 2 rows for the 2 alleles; each column is one sample.
        * A square is filled if the allele is present.
        * It is red if the sample is an affected one, and blue otherwise.
        * One can obtain more details on the corresponding samples by clicking on the
          squares: it opens a 'lookup' window with more details on that variant.

        In the figure, the scenario is recessive: the parents are heterozygous carriers,
        the affected child - in red - is homozygous alt, and the other unaffected son can
        be either non-carrier or carry one copy.

.. container:: clear

    |nbsp|


.. _lookup:

The lookup window
.................

.. container:: twocol

    .. container:: leftside

        Different actions will trigger
        a new window with details about the clicked item, in the top-left corner.

        For instance, clicking a gene name will give links to Ensembl, Entrez, OMIM etc.
        Clicking an HGVS annotation will show the affected transcript.
        Clicking a genotypes box will show details on the samples:
        the figure here corresponds to one of the variants above, and shows that the
        two first non-affected individuals are the parents, followed by an affected son
        and an unaffected one.

    .. container:: rightside

        .. figure:: /images/lookup.png
           :scale: 80%

.. container:: clear

    |nbsp|


.. _bookmarks:

Sharing, and the usage of bookmarks
...................................

.. container:: twocol

    .. container:: floatleft

        .. figure:: /images/bookmark-save.png

    .. container:: floatleft

        .. figure:: /images/bookmark-load.png

.. container:: clear

    |nbsp|

The **URL** already reflects the state of the application and can be **shared with another user**
who possesses an account and has been granted access to the same database.
Another user opening the URL you give him will see what you see.
To facilitate this action, the URL can be copied to clipboard with the rightmost button of the
bookmarks utils. It can also be saved as a browser's "favorite".

For saving purposes however, we advise to use the in-app bookmarks for the following reasons:

* They are saved to the database and thus cannot be lost.
* In case the underlying API changes, bookmarks will be adapted, but URLs will become invalid.
* One can enter a description to remember the context.
* In a future extension, bookmarks could be browsed and organized by the user in a dedicated page.
  The maintenance of browser favorites is the responsibility of the user.


.. _samples-selection:

Samples selection
-----------------

.. figure:: /images/samples-annot.png
   :width:  100%
   :alt: Samples selection table

A)  **Variants summary**. It shows the number of filtered variants
    (which changes according to the samples selection).
    Clicking it brings back to the :ref:`variants-table`.
B)  **Selection tools**: select/deselect respectively all samples, only non affected, or affected.
    The search bar helps finding samples; it does not actually change the selection.
C)  Add/remove an entire **family** from the selection.
D)  Add/remove an **individual** from the selection.
E)  Mark the **phenotype** of an individual as affected/non affected
    (in case there was a mistake in the pedigree from the start,
    or if one is not sure and wants to try both).
F)  **Restore** the initial samples selection. By default, only the first family is selected,
    and the phenotypes are restored to that of the initial pedigree.
G)  Alternative link to return to the variants table.

