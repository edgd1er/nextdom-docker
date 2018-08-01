<?php

/* This file is part of NextDom.
*
* NextDom is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* NextDom is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with NextDom. If not, see <http://www.gnu.org/licenses/>.
*/

use NextDom\Helpers\PrepareView;
use NextDom\Helpers\Status;
use NextDom\Managers\JeeObjectManager;
use NextDom\Managers\UpdateManager;

global $homeLink;

$pluginMenu = PrepareView::getPluginMenu();
$panelMenu = PrepareView::getPanelMenu();
$nbMessage = message::nbMessage();
$displayMessage = '';
if ($nbMessage == 0) {
    $displayMessage = 'display : none;';
}
$nbUpdate = UpdateManager::nbNeedUpdate();
$displayUpdate = '';
if ($nbUpdate == 0) {
    $displayUpdate = 'display : none;';
}

?>
<body class="hold-transition skin-blue sidebar-mini fixed sidebar-collapse">
<header class="main-header">

    <!-- Logo -->
    <a href="<?php echo $homeLink; ?>" class="logo">
        <!-- mini logo for sidebar mini 50x50 pixels -->
        <span class="logo-mini"><img src="/core/img/NextDom_Square_AlphaBlackBlue.png" style="height:40px;width:auto"></img></span>
        <!-- logo for regular state and mobile devices -->
        <span class="logo-lg"><img src="/core/img/NextDom_Wide_AlphaBlueBlack.png" style="height:40px;width:auto"></img></span>
    </a>

    <!-- Header Navbar: style can be found in header.less -->
    <nav class="navbar navbar-static-top">
        <!-- Sidebar toggle button-->
        <a href="#" class="sidebar-toggle" data-toggle="push-menu" role="button">
            <span class="sr-only">Toggle navigation</span>
        </a>
        <!-- Navbar Right Menu -->
        <div class="navbar-custom-menu">
            <ul class="nav navbar-nav">
                <!-- Notifications: style can be found in dropdown.less -->
                <li class="dropdown notifications-menu">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa fa-bell-o"></i>
                        <span class="label label-warning"><?php echo $nbMessage; ?></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li class="header">You have <?php echo $nbMessage; ?>  notifications</li>

                        </li>
                        <li class="footer"><a href="index.php?v=d&p=update">View all</a></li>
                    </ul>
                </li>
                <!-- Tasks: style can be found in dropdown.less -->
                <li class="dropdown tasks-menu">
                    <a href="#" class="dropdown-toggle" data-toggle="dropdown">
                        <i class="fa fa-flag-o"></i>
                        <span class="label label-danger"><?php echo $nbUpdate; ?></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li class="header">You have <?php echo $nbUpdate; ?> tasks</li>
                        <li>
                            <!-- inner menu: contains the actual data -->

                            <!-- end task item -->

                        </li>
                        <li class="footer">
                            <a href="index.php?v=d&p=update">View all tasks</a>
                        </li>
                    </ul>
                </li>

                <!-- Control Sidebar Toggle Button -->
                <li>
                    <a href="#" data-toggle="control-sidebar"><i class="fa fa-gears"></i></a>
                </li>
            </ul>
        </div>

    </nav>
</header>
<!-- Left side column. contains the logo and sidebar -->
<aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
        <!-- sidebar menu: : style can be found in sidebar.less -->
        <ul class="sidebar-menu" data-widget="tree">
            <li class="header">MENU PRINCIPAL</li>
            <li class="active treeview menu-open">
                <a href="#"><i class="fa fa-home"></i> <span>Acceuil</span><span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span></a>
                <ul class="treeview-menu">
                    <li class="treeview">
                        <a href="#"><i class="fa fa-dashboard"></i> Dashboard <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span></a>
                        <ul class="treeview-menu">

                            <li class="treeview-menu">
                                <?php
                                foreach (JeeObjectManager::buildTree(null, false) as $objectLi) {
                                    echo '<li><a href="index.php?v=d&p=dashboard&object_id=' . $objectLi->getId() . '">' . $objectLi->getHumanName(true) . '</a></li>';
                                }
                                ?>
                            </li>

                        </ul>
                    </li>
                    <li class="treeview">
                        <a href="#"><i class="fa fa-picture-o"></i> Vue <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span></a>
                        <ul class="treeview-menu">

                            <li class="treeview-menu">
                                <?php
                                foreach (view::all() as $viewMenu) {
                                    echo '<li><a href="index.php?v=d&p=view&view_id=' . $viewMenu->getId() . '">' . trim($viewMenu->getDisplay('icon')) . ' ' . $viewMenu->getName() . '</a></li>';
                                }
                                ?>
                            </li>

                        </ul>
                    </li>
                    <li class="treeview">
                        <a href="#"><i class="fa fa-paint-brush"></i> Design <span class="pull-right-container"><i class="fa fa-angle-left pull-right"></i></span></a>
                        <ul class="treeview-menu">

                            <li class="treeview-menu">
                                <?php
                                foreach (planHeader::all() as $planMenu) {
                                    echo '<li><a href="index.php?v=d&p=plan&plan_id=' . $planMenu->getId() . '">' . trim($planMenu->getConfiguration('icon') . ' ' . $planMenu->getName()) . '</a></li>';
                                }
                                ?>
                            </li>
                        </ul>
                    </li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-stethoscope"></i>
                    <span>Analyse</span>
                    <span class="pull-right-container">
                        <i class="fa fa-angle-left pull-right"></i>
                    </span>
                </a>
                <ul class="treeview-menu">
                    <li><a href="index.php?v=d&p=history"><i class="fa fa-bar-chart-o"></i> {{Historique}}</a></li>
                    <li><a href="index.php?v=d&p=report"><i class="fa fa-newspaper-o"></i> {{Rapport}}</a></li>
                    <li><a href="#" id="bt_showEventInRealTime"><i class="fa fa-tachometer"></i> {{Temps réel}}</a></li>
                    <li><a href="index.php?v=d&p=log"><i class="fa fa-file-o"></i> {{Logs}}</a></li>
                    <li><a href="index.php?v=d&p=eqAnalyse"><i class="fa fa-battery-full"></i> {{Equipements}}</a></li>
                    <li><a href="index.php?v=d&p=health"><i class="fa fa-medkit"></i> {{Santé}}</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-laptop"></i>
                    <span>Outils</span>
                    <span class="pull-right-container">
                        <i class="fa fa-angle-left pull-right"></i>
                    </span>
                </a>
                <ul class="treeview-menu">
                    <li><a href="index.php?v=d&p=object"><i class="fa fa-picture-o"></i> {{Objets}}</a></li>
                    <li><a href="index.php?v=d&p=interact"><i class="fa fa-comments-o"></i> {{Interactions}}</a></li>
                    <li><a href="index.php?v=d&p=display"><i class="fa fa-th"></i> {{Résumé domotique}}</a></li>
                    <li><a href="index.php?v=d&p=scenario"><i class="fa fa-cogs"></i> {{Scénarios}}</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-share"></i> <span>Plugins</span>
                    <span class="pull-right-container">
                        <i class="fa fa-angle-left pull-right"></i>
                    </span>
                </a>
                <ul class="treeview-menu">
                    <li><a href="index.php?v=d&p=plugin"><i class="fa fa-tags"></i> {{Gestion des plugins}}</a></li>
                    <li class="treeview-menu">
                        <?php echo $pluginMenu; ?>
                    </li>
                    </li>


                </ul>

        </ul>
    </section>
    <!-- /.sidebar -->
</aside>
<!-- Control Sidebar -->
<aside class="control-sidebar control-sidebar-dark">
    <!-- Create the tabs -->
    <ul class="nav nav-tabs nav-justified control-sidebar-tabs">
        <li><a href="#control-sidebar-settings-tab" data-toggle="tab"><i class="fa fa-gears"></i></a></li>
        <li><a href="#control-sidebar-tools-tab" data-toggle="tab"><i class="fa fa-wrench"></i></a></li>
    </ul>
    <!-- Tab panes -->
    <div class="tab-content">
        <div class="tab-pane active" id="control-sidebar-settings-tab">
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=administration"><i class="fa fa-wrench"></i> {{Configuration}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=backup"><i class="fa fa-floppy-o"></i> {{Sauvegardes}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=migration"><i class="fa fa-upload"></i> {{Migration depuis jeedom}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=update"><i class="fa fa-refresh"></i> {{Centre de mise à jour}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=cron"><i class="fa fa-tasks"></i> {{Moteur de tâches}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=custom"><i class="fa fa-pencil-square-o"></i> {{Personnalisation avancée}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=user"><i class="fa fa-users"></i> {{Utilisateurs}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=profils"><i class="fa fa-briefcase"></i> {{Profil}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=m"><i class="fa fa-mobile"></i> {{Version mobile}}</a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&p=log"><i class="fa fa-info-circle"></i> {{Version}}<?php echo nextdom::version(); ?></a></div>
            <div><a class="control-sidebar-heading" href="index.php?v=d&logout=1" class="noOnePageLoad"><i class="fa fa-circle-o"></i> {{Se déconnecter}}</a></div>
            <?php
            if (nextdom::isCapable('sudo')) {
                echo '<div><a class="control-sidebar-heading" id="bt_rebootSystem" state="0"><i class="fa fa-repeat"></i> {{Redémarrer}}</a></div>';
                echo '<div><a class="control-sidebar-heading" id="bt_haltSystem" state="0"><i class="fa fa-power-off"></i> {{Eteindre}}</a></div>';
            }
            ?>
        </div>
        <div class="tab-pane" id="control-sidebar-tools-tab">
            <h4 class="control-sidebar-heading">Layout Options</h4>
            <div class="form-group">
                <label class="control-sidebar-subheading"><input type="checkbox"data-layout="sidebar-collapse"class="pull-right"/>Toggle Sidebar</label>
                <p>Toggle the left sidebar\'s state (open or collapse)</p>
            </div>
        <div class="form-group">
            <label class="control-sidebar-subheading"><input type="checkbox"data-enable="expandOnHover"class="pull-right"/>Sidebar Expand on Hover</label>
            <p>Let the sidebar mini expand on hover</p>
        </div>
        <div class="form-group">
            <label class="control-sidebar-subheading"><input type="checkbox"data-controlsidebar="control-sidebar-open"class="pull-right"/>Toggle Right Sidebar Slide</label>
            <p>Toggle between slide over content and push content effects</p>'
        </div>
        <div class="form-group"><label class="control-sidebar-subheading"><input type="checkbox"data-sidebarskin="toggle"class="pull-right"/>Toggle Right Sidebar Skin</label>
            <p>Toggle between dark and light skins for the right sidebar</p>
        </div>
        <ul class="list-unstyled clearfix">
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-nextdom" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #367fa9"></span>
                        <span class="bg-light-blue" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">skin-nextdom</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-nextdom" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #367fa9"></span>
                        <span class="bg-light-blue" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">skin-nextdom-light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-nextdom-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #367fa9"></span>
                        <span class="bg-light-blue" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Blue</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-black" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div style="box-shadow: 0 0 2px rgba(0,0,0,0.1)" class="clearfix">
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #fefefe"></span>
                        <span style="display:block; width: 80%; float: left; height: 7px; background: #fefefe"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Black</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-purple" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-purple-active"></span>
                        <span class="bg-purple" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Purple</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-green" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-green-active"></span>
                        <span class="bg-green" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Green</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;"><a href="javascript:void(0)" data-skin="skin-red" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-red-active"></span>
                        <span class="bg-red" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Red</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-yellow" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-yellow-active"></span>
                        <span class="bg-yellow" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #222d32"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin">Yellow</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;"><a href="javascript:void(0)" data-skin="skin-blue-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #367fa9"></span>
                        <span class="bg-light-blue" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Blue Light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-black-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div style="box-shadow: 0 0 2px rgba(0,0,0,0.1)" class="clearfix">
                        <span style="display:block; width: 20%; float: left; height: 7px; background: #fefefe"></span>
                        <span style="display:block; width: 80%; float: left; height: 7px; background: #fefefe"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Black Light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-purple-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-purple-active"></span>
                        <span class="bg-purple" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Purple Light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-green-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-green-active"></span>
                        <span class="bg-green" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Green Light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-red-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-red-active"></span>
                        <span class="bg-red" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Red Light</p>
            </li>
            <li style="float:left; width: 33.33333%; padding: 5px;">
                <a href="javascript:void(0)" data-skin="skin-yellow-light" style="display: block; box-shadow: 0 0 3px rgba(0,0,0,0.4)" class="clearfix full-opacity-hover">
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 7px;" class="bg-yellow-active"></span>
                        <span class="bg-yellow" style="display:block; width: 80%; float: left; height: 7px;"></span>
                    </div>
                    <div>
                        <span style="display:block; width: 20%; float: left; height: 20px; background: #f9fafc"></span>
                        <span style="display:block; width: 80%; float: left; height: 20px; background: #f4f5f7"></span>
                    </div>
                </a>
                <p class="text-center no-margin" style="font-size: 12px">Yellow Light</p>
            </li>
        </ul>
    </div>
</aside>
<!-- /.control-sidebar -->

<!-- Content Wrapper. Contains page content -->
<div class="content-wrapper">
    <!-- Content Header (Page header) -->
