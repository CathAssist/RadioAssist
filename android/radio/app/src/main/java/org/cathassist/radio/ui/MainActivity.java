package org.cathassist.radio.ui;

import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.app.FragmentManager;
import android.os.Bundle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.support.v4.widget.DrawerLayout;

import org.cathassist.radio.R;
import org.cathassist.radio.model.Channel;


public class MainActivity extends AppCompatActivity
        implements NavigationDrawerCallbacks {

    private static MainActivity mMainActivity = null;
    public static MainActivity getMainActivity()
    {
        return mMainActivity;
    }

    private Channel mChannelPlaying = null;
    private Channel mChannelShowing = null;

    private int mCurrentFragmentPosition = 0;
    private Toolbar mToolbar;
    /**
     * Fragment managing the behaviors, interactions and presentation of the navigation drawer.
     */
    private NavigationDrawerFragment mNavigationDrawerFragment = null;

    private TracksFragment mTracksFragment = null;

    /**
     * Used to store the last screen title. For use in {@link #restoreActionBar()}.
     */
    private CharSequence mTitle;

    public void setChannelPlaying(Channel _c)
    {
        mChannelPlaying = _c;
    }
    public Channel getChannelPlaying()
    {
        return mChannelPlaying;
    }

    public void setChannelShowing(Channel _c)
    {
        mChannelShowing = _c;
        mTracksFragment.setTracks(mChannelShowing.getItems());
    }
    public Channel getChannelShowing()
    {
        return mChannelShowing;
    }

    public NavigationDrawerFragment getmNavigationDrawerFragment()
    {
        return mNavigationDrawerFragment;
    }

    public TracksFragment getmTracksFragment()
    {
        return mTracksFragment;
    }


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mMainActivity = this;

        setContentView(R.layout.activity_main);
        mToolbar = (Toolbar) findViewById(R.id.toolbar_actionbar);
        setSupportActionBar(mToolbar);

        getSupportActionBar().setDisplayHomeAsUpEnabled(true);

        mNavigationDrawerFragment = (NavigationDrawerFragment)
                getFragmentManager().findFragmentById(R.id.fragment_drawer);
        mTitle = getTitle();

        // Set up the drawer.
        mNavigationDrawerFragment.setup(
                R.id.fragment_drawer,
                (DrawerLayout) findViewById(R.id.drawer),
                mToolbar);

        mToolbar.setNavigationOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if(mCurrentFragmentPosition == 0)
                {
                    if(mNavigationDrawerFragment.isDrawerOpen())
                    {
                        mNavigationDrawerFragment.closeDrawer();
                    }
                    else
                    {
                        mNavigationDrawerFragment.openDrawer();
                    }
                }
                else
                {
                    onBackPressed();
                }
            }
        });

        //
        mTracksFragment = (TracksFragment)getFragmentManager()
                .findFragmentById(R.id.fragment_drawer_tracks);
        mTracksFragment.setup((DrawerLayout) findViewById(R.id.drawer));
        mTracksFragment.setLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
    }

    @Override
    public void onNavigationDrawerItemSelected(int position) {
        // update the main content by replacing fragments
        mCurrentFragmentPosition = position;
        FragmentManager fragmentManager = getFragmentManager();
        switch (position)
        {
            case 0:
                fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
                fragmentManager.beginTransaction()
                        .replace(R.id.container, ChannelListFragment.newInstance(position + 1))
                        .commit();

                if(mNavigationDrawerFragment != null)
                    mNavigationDrawerFragment.getActionBarDrawerToggle().setDrawerIndicatorEnabled(true);

                if(mTracksFragment != null)
                    mTracksFragment.setLockMode(DrawerLayout.LOCK_MODE_LOCKED_CLOSED);
                break;
            case 1:
                fragmentManager.popBackStack(null, FragmentManager.POP_BACK_STACK_INCLUSIVE);
                fragmentManager.beginTransaction()
                        .replace(R.id.container, ChannelPlayFragment.newInstance(mChannelShowing, position + 1))
                        .addToBackStack(null)
                        .commit();

                mNavigationDrawerFragment.getActionBarDrawerToggle().setDrawerIndicatorEnabled(false);
                break;
            case 2:
                startActivity(new Intent(getApplicationContext(), SettingsActivity.class));
                break;
            case 7:
                break;
            default:
                break;
        }
    }

    public void onSectionAttached(int number) {
        switch (number) {
            case 1:
                mTitle = getString(R.string.section_list);
                break;
            case 2:
                mTitle = getString(R.string.section_playing);
                break;
        }
    }

    public void restoreActionBar() {
        ActionBar actionBar = getSupportActionBar();
        actionBar.setNavigationMode(ActionBar.NAVIGATION_MODE_STANDARD);
        actionBar.setDisplayShowTitleEnabled(true);
        actionBar.setTitle(mTitle);
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {

        return super.onCreateOptionsMenu(menu);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();
        switch (id)
        {
        }

        return super.onOptionsItemSelected(item);
    }

    @Override
    public void onBackPressed()
    {
        if(mCurrentFragmentPosition != 0){
            mNavigationDrawerFragment.selectItem(0);
//            onNavigationDrawerItemSelected(0);
        }
        else {
            finish();
        }
    }

    @Override
    public boolean onNavigateUp()
    {

        return true;
    }

    @Override
    public boolean onSupportNavigateUp() {
        //This method is called when the up button is pressed. Just the pop back stack.
        getFragmentManager().popBackStack();
        return true;
    }
}
