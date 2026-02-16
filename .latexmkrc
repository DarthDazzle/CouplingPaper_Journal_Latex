# Output directory for auxiliary files (keep PDF in root)
$out_dir = 'build';

# PDF generation settings
$pdf_mode = 1;  # Use pdflatex
$postscript_mode = $dvi_mode = 0;

# Enable recorder for better dependency tracking
$recorder = 1;

# Ensure LaTeX can find files in parent directory when output dir is used
$ENV{'TEXINPUTS'} = './/:' . ($ENV{'TEXINPUTS'} || '');
$ENV{'BIBINPUTS'} = './/:' . ($ENV{'BIBINPUTS'} || '');
$ENV{'BSTINPUTS'} = './/:' . ($ENV{'BSTINPUTS'} || '');

# Move PDF back to root after compilation  
$success_cmd = 'powershell -Command "Copy-Item build/%A.pdf . -Force"';

# Continuous preview and cleanup settings
$preview_continuous_mode = 0;
$clean_ext = "synctex.gz synctex.gz(busy) run.xml tex.bak bbl bcf fdb_latexmk run tdo %R-blx.bib";

# Better handling of bibtex
$bibtex_use = 2;  # Run bibtex when needed
