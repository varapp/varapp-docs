
REST API
========

Below are listed all available queries through HTTP GET requests.
In case they are not up to date, all valid url patterns are listed in "varapp/urls.py".
Most queries return data in JSON format.

* ``/varapp``: prints a "Hello World !" message indicating that the service is online.
* ``/varapp/samples``: returns all Samples.
* ``/varapp/variants``: returns all Variants.

Below are given the possible suffixes to ``/varapp/variants/``, with the value types in brackets.

* ``[<>=]`` : expects a comparison operator, such as
  ``>=``, ``<=``, ``>``, ``<``, ``=`` .
* ``<0/1>`` : expects a binary value. 1, true, True, TRUE count as true, everything else as false.
    Not specifying the argument also counts as true.

Variant attributes filters
--------------------------

They all correspond to 'WHERE' SQL statements,
based on existing, non-binary fields in the Gemini database.

**Location filters**

* ``filter=gene=<str>``: Gene name (gene symbol).
* ``filter=transcript=<str>``: Ensembl transcript ID.
* ``filter=location=<str>``: Genomic coordinates, given as "chrom:start-end".

**Quality filters:**

* ``filter=quality[<>=]<float>``: variant quality score threshold.
* ``filter=filter``:
    whether the variant has passed through filters such as VQSR Tranches.

    - ``filter=<0/1>``: returns variants that passed through all filters.
    - ``filter=<str,str,...>``: given a comma-separated list of filter names,
        returns also variants that were stopped by these particular filters.
        There is no check that the given filter names exist; if they don't
        they are simply ignored.

**Frequency filters:**

* ``filter=in_dbsnp=<0/1>``: return only variants absent (0) / present (1) in dbSNP.
* ``filter=in_1kg=<0/1>``: same for 1000 Genomes.
* ``filter=in_esp=<0/1>``: same for ESP.
* ``filter=frequency=<db>=<pop>[comp]<value>``: filter by variant frequency in the 1000 Genomes/ESP databases.
    - ``<db>``: the database name, can be ``'1kg'`` (1000 Genomes) or ``'esp'`` (ESP).
    - ``<pop>``: the population name:
        + ``'all'``, ``'amr'``, ``'eas'``, ``'sas'``, ``'afr'``, ``'eur'`` for 1000 Genomes;
        + ``'all'``, ``'ea'``, ``'aa'`` for ESP.
    - ``[comp]``: one of ``<=``, ``=>``, ``<``, ``>``.
    - ``<value>``: a float, the frequency threshold.

**Impact filters:**

* ``filter=is_exonic=<0/1>``: whether the variant is inside an exon.
* ``filter=is_coding=<0/1>``: whether the variant is inside a coding region.
* ``filter=is_lof=<0/1>``: whether the variant is predicted to disrupt the function of the protein.
* ``filter=impact=<str,str,...>``: whether the variant is inside an exon.
* ``filter=impact_so=<str,str,...>``: whether the variant is inside an exon.
* ``filter=impact_severity=<HIGH/MED/LOW>``: whether the variant is inside an exon.

Possible values for ``impact`` and ``impact_so`` are listed `here in the Gemini doc pages <http://gemini.readthedocs.org/en/latest/content/database_schema.html#details-of-the-impact-and-impact-severity-columns>`_ .

Samples selection
-----------------

* ``samples=<group_name>=<str,str,...>``: select groups of samples.
    Associates a comma-separated list of sample names to a *group_name*.
    A new group *group_name* is created each time this is called.

Genotypes filter
----------------

A filter on samples genotype. It requires a samples selection (see above),
and is based on the selection's group names.

.. warning::

    Filtering on the genotype requires to extract every variant passing the
    attributes filters, in order to decode its binary genotypes fields.
    That means that if no previous filtering is done, this one can be very slow
    no matter how many results it eventually returns. Consider filtering out
    common variants first.

* ``genotypes=dominant``: return only variants that are **ref/ref** in every sample of
    the 'not_affected' group, and mutated in every sample of the 'affected' group.
* ...

Pagination
----------

To limit the return size of large queries.

Pagination will nenever reduce the time required for a query
(only the size of the data sent to the client).

* ``limit=<int N>``: return only the first N results.
* ``offset=<int N>``: skip the first N results.

Application order
-----------------

Whatever the ordered you entered the different options in,
actions will always performed in the following order:

1. Samples selection and grouping
2. Variant attributes filters: location, quality, frequency, impact.
3. Genotype filters
4. Pagination

Examples
--------

Everything that has an entry in dbSNP::

    /varapp/variants?filter=in_dbsnp

Same, limited to 10 results and skipping the first 5::

    /varapp/variants?filter=in_dbsnp=1&limit=10&offset=5

Everything that does not have an entry in dbSNP::

    /varapp/variants?filter=in_dbsnp=0

Quality >= 1000:::

    /varapp/variants?filter=quality>=1000

Quality < 100, only samples KLS1 and KLS2::

    /varapp/variants?filter=quality<100&samples=KLS1,KLS2

Loss-of-function variants in gene GAPDH::

    /varapp/variants?filter=is_lof&filter=gene="Gapdh"

10 variants in transcript ENST00X::

    /varapp/variants?filter=transcript="ENST00X"&limit=10

Variants with low frequency in the 1000 Genomes database::

    /varapp/variants?filter=frequency=1kg=all<=0.01

Show only genotypes for samples in group1=[KLS1] and group2=[KL2,KL3]::

    /varapp/variants?limit=10&samples=group1=KLS1&samples=group2=KL2,KL3

