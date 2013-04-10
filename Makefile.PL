use 5.008;
use ExtUtils::MakeMaker;
WriteMakefile(
    NAME              => 'Test::More::Ext',
    VERSION_FROM      => 'lib/Test/More/Ext.pm',
    PREREQ_PM         => {
        'Test::More' => 0.98,
    },
    ($] >= 5.005 ?     ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM  => 'lib/Test/More/Ext.pm',
       AUTHOR         => 'Sunao Tanabe <sunao.tanabe@gmail.com>') : ()),
);
